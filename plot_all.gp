set terminal pngcairo size 900,600 font "Arial,12" enhanced
set datafile separator whitespace

# ============================================
# Grafik 1: Pembacaan ADC Dual Channel
# ============================================
set output 'ETS_LATEX/grafik_adc.png'
set title "Pembacaan ADC: V_{total} (GPIO9) vs V_{sense} (GPIO10)" font "Arial,14"
set xlabel "Sampel ke-"
set ylabel "Nilai ADC (0-4095)"
set grid
set key top right box
set style line 1 lc rgb "#2196F3" lw 2 pt 7 ps 1.0
set style line 2 lc rgb "#FF9800" lw 2 pt 5 ps 1.0
plot 'data.dat' using 0:1 with linespoints ls 1 title "ADC1 - V_{total} (GPIO9)", \
     'data.dat' using 0:2 with linespoints ls 2 title "ADC2 - V_{sense} (GPIO10)"

# ============================================
# Grafik 2: Tegangan Terukur (mV)
# ============================================
set output 'ETS_LATEX/grafik_tegangan.png'
set title "Tegangan Terukur: V_{total} vs V_{sense}" font "Arial,14"
set xlabel "Sampel ke-"
set ylabel "Tegangan (mV)"
set key top right box
set style line 1 lc rgb "#42A5F5" lw 2 pt 7 ps 1.0
set style line 2 lc rgb "#EF5350" lw 2 pt 5 ps 1.0
plot 'data.dat' using 0:3 with linespoints ls 1 title "V_{total} (mV)", \
     'data.dat' using 0:4 with linespoints ls 2 title "V_{sense} (mV)"

# ============================================
# Grafik 3: Rx Kompensasi vs Sampel
# ============================================
set output 'ETS_LATEX/grafik_rx.png'
set title "Resistansi Sensor Terkompensasi (R_x)" font "Arial,14"
set xlabel "Sampel ke-"
set ylabel "Rx Kompensasi (Ohm)"
set key top right box
set style line 1 lc rgb "#4CAF50" lw 2 pt 7 ps 1.2
plot 'data.dat' using 0:6 with linespoints ls 1 title "Rx Kompensasi (Ohm)"

# ============================================
# Grafik 4: Rx Raw vs Rx Kompensasi (Log Scale)
# ============================================
set output 'ETS_LATEX/grafik_perbandingan.png'
set title "Perbandingan: Rx Raw vs Rx Kompensasi" font "Arial,14"
set xlabel "Sampel ke-"
set ylabel "Resistansi (Ohm)"
set key top left box
set logscale y
set format y "10^{%L}"
set style line 1 lc rgb "#F44336" lw 2 pt 7 ps 1.0
set style line 2 lc rgb "#4CAF50" lw 2 pt 5 ps 1.0
plot 'data.dat' using 0:5 with linespoints ls 1 title "Rx Raw (dgn error kabel)", \
     'data.dat' using 0:6 with linespoints ls 2 title "Rx Kompensasi (tanpa error)"
unset logscale y
set format y "%g"

# ============================================
# Grafik 5: Error Hambatan Kabel (%)
# ============================================
set output 'ETS_LATEX/grafik_error.png'
set title "Persentase Error Akibat Hambatan Kabel" font "Arial,14"
set xlabel "Sampel ke-"
set ylabel "Error (%)"
set key top right box
set style line 1 lc rgb "#F44336" lw 2 pt 7 ps 1.2
set style fill transparent solid 0.15
plot 'data.dat' using 0:7 with filledcurves y1=0 lc rgb "#F44336" notitle, \
     'data.dat' using 0:7 with linespoints ls 1 title "Error Kabel (%)"

print "Selesai! 5 grafik PNG telah dibuat di folder ETS_LATEX/"
