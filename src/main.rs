#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{
    analog::adc::{Adc, AdcConfig, Attenuation},
    delay::Delay,
    gpio::{Level, Output},
};
use esp_println::println;
use nb::block;

esp_bootloader_esp_idf::esp_app_desc!();

#[esp_hal::main]
fn main() -> ! {
    let peripherals = esp_hal::init(esp_hal::Config::default());
    let delay = Delay::new();

    // Dual ADC: GPIO9 (V_total di Node A) dan GPIO10 (V_sense di wiper)
    let mut adc1_config = AdcConfig::new();
    let mut pin_vtotal = adc1_config.enable_pin(peripherals.GPIO9, Attenuation::_11dB);
    let mut pin_vsense = adc1_config.enable_pin(peripherals.GPIO10, Attenuation::_11dB);
    let mut adc1 = Adc::new(peripherals.ADC1, adc1_config);

    // LED indikator pada GPIO4
    let mut led = Output::new(peripherals.GPIO4, Level::Low, Default::default());

    // Parameter komponen
    let r_ref: f64 = 10_000.0;
    let v_supply: f64 = 3.3;
    let adc_max: f64 = 4095.0;

    println!("=== Akuisisi Sensor Resistif 3-Wire (Dual ADC) ===");
    println!("GPIO9=V_total | GPIO10=V_sense | GPIO4=LED");
    println!("ADC1 ADC2 Vtot(mV) Vsns(mV) Rx_raw Rx_komp Error%");
    println!("---");

    loop {
        // Rata-rata 16 sampel untuk stabilitas
        let mut t1: u32 = 0;
        let mut t2: u32 = 0;
        for _ in 0..16 {
            let v1: u16 = block!(adc1.read_oneshot(&mut pin_vtotal)).unwrap();
            let v2: u16 = block!(adc1.read_oneshot(&mut pin_vsense)).unwrap();
            t1 += v1 as u32;
            t2 += v2 as u32;
        }
        let adc1_avg = t1 / 16;
        let adc2_avg = t2 / 16;

        let v_total = (adc1_avg as f64 / adc_max) * v_supply;
        let v_sense = (adc2_avg as f64 / adc_max) * v_supply;
        let vt_mv = (v_total * 1000.0) as u32;
        let vs_mv = (v_sense * 1000.0) as u32;

        // Hitung Rx_raw (dari V_total, mengandung error kabel)
        let rx_raw = if v_total < v_supply - 0.01 {
            r_ref * v_total / (v_supply - v_total)
        } else {
            99999.0
        };

        // Hitung Rx_sense (dari V_sense, setelah kompensasi Rw1)
        let rx_sense = if v_sense < v_supply - 0.01 {
            r_ref * v_sense / (v_supply - v_sense)
        } else {
            99999.0
        };

        // Hambatan kabel terukur dan error
        let rw_calc = rx_raw - rx_sense;
        let error_pct = if rx_sense > 1.0 && rx_sense < 99999.0 {
            (rw_calc / rx_sense) * 100.0
        } else {
            0.0
        };

        // LED menyala jika pengukuran stabil
        if rx_raw < 99999.0 && rx_sense < 99999.0 && error_pct.abs() < 5.0 {
            led.set_high();
        } else {
            led.set_low();
        }

        // SELALU tampilkan 7 kolom
        println!(
            "{} {} {} {} {:.1} {:.1} {:.2}",
            adc1_avg, adc2_avg, vt_mv, vs_mv, rx_raw, rx_sense, error_pct
        );

        delay.delay_millis(500);
    }
}
