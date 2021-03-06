
FM_SHIFTS = [
    [ 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77 ],
    [ 0x77, 0x77, 0x77, 0x77, 0x72, 0x72, 0x72, 0x72 ],
    [ 0x77, 0x77, 0x77, 0x72, 0x72, 0x72, 0x17, 0x17 ],
    [ 0x77, 0x77, 0x72, 0x72, 0x17, 0x17, 0x12, 0x12 ],
    [ 0x77, 0x77, 0x72, 0x17, 0x17, 0x17, 0x12, 0x07 ],
    [ 0x77, 0x77, 0x17, 0x12, 0x07, 0x07, 0x02, 0x01 ],
    [ 0x77, 0x77, 0x17, 0x12, 0x07, 0x07, 0x02, 0x01 ],
    [ 0x77, 0x77, 0x17, 0x12, 0x07, 0x07, 0x02, 0x01 ]
];

File.open "fm_muls.txt",?w do |f1|
    File.open "fm_tbl.txt",?w do |f2|
        (0..7).each do |lfoabs|
            (0..7).each do |sens|
                sh1 = FM_SHIFTS[sens][lfoabs] & 7
                sh2 = (FM_SHIFTS[sens][lfoabs]>>4) & 7
                mul = ((1.0/(1<<sh1) + 1.0/(1<<sh2))*128)
                mul *= 1<<(sens-5) if sens > 5
                f1.write "Sens #{sens}, val #{lfoabs} : #{mul}\n"
                f2.write "word #{"%3d"%(mul.to_i)} ' Sens #{sens} val #{lfoabs}\n"
            end
        end 
    end
end