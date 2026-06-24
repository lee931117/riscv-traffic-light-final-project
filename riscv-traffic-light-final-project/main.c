#define LED_REG     (*(volatile unsigned int*)0x10000000)
#define SW_REG      (*(volatile unsigned int*)0x10000004)
#define BTN_REG     (*(volatile unsigned int*)0x10000008)
#define SEG_REG     (*(volatile unsigned int*)0x1000000C)
#define TIMER_REG   (*(volatile unsigned int*)0x10000010)

#define LED_GREEN   0x1
#define LED_YELLOW  0x2
#define LED_RED     0x4
#define LED_AUTO    0x8

void delay_ticks(unsigned int ticks) {
    unsigned int start = TIMER_REG;
    while ((TIMER_REG - start) < ticks) {
        // busy wait
    }
}

// Basys 3 是 100MHz，這裡先用比較短的展示時間
void delay_demo_1s() {
    delay_ticks(10000000);   // 約 0.1 秒，如果太快/太慢再調
}

int button_pressed_edge(int *last_btn) {
    int now = BTN_REG & 0x1;
    int pressed = (now && !(*last_btn));
    *last_btn = now;
    return pressed;
}

void show_state(unsigned int led_value, int seconds, int *last_btn, int *emergency) {
    int t;

    LED_REG = led_value | LED_AUTO;

    for (t = seconds; t >= 0; t--) {
        SEG_REG = t;

        delay_demo_1s();

        if (button_pressed_edge(last_btn)) {
            *emergency = 1;
            return;
        }
    }
}

int main() {
    int state = 0;       // 0=red, 1=yellow, 2=green
    int emergency = 0;
    int last_btn = 0;
    int flash = 0;

    while (1) {
        if (button_pressed_edge(&last_btn)) {
            emergency = !emergency;
        }

        if (emergency) {
            SEG_REG = 99;

            if (flash) {
                LED_REG = LED_RED;
            } else {
                LED_REG = 0x0;
            }

            flash = !flash;
            delay_demo_1s();

            if (button_pressed_edge(&last_btn)) {
                emergency = 0;
                state = 0;
            }
        } else {
            if (state == 0) {
                // 紅燈
                show_state(LED_RED, 9, &last_btn, &emergency);
                state = 1;
            } else if (state == 1) {
                // 黃燈
                show_state(LED_YELLOW, 3, &last_btn, &emergency);
                state = 2;
            } else {
                // 綠燈
                show_state(LED_GREEN, 9, &last_btn, &emergency);
                state = 0;
            }
        }
    }

    return 0;
}