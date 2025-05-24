import 'dart:io';

var cpuDatas = [
["AMD Ryzen AI Max+ PRO 395",16,32,"3GHZ","5.1GHZ","","16 MB","64 MB",55,"Radeon 8060S Graphics",40,"2900MHZ"],
["AMD Ryzen AI Max PRO 390",12,24,"3.2GHZ","5GHZ","","12 MB","64 MB",55,"Radeon 8050S Graphics",32,"2800MHZ"],
["AMD Ryzen AI Max PRO 385",8,16,"3.6GHZ","5GHZ","","8 MB","32 MB",55,"Radeon 8050S Graphics",32,"2800MHZ"],
["AMD Ryzen AI Max PRO 380",6,12,"3.6GHZ","4.9GHZ","","6 MB","16 MB",55,"Radeon 8040S Graphics",16,"2800MHZ"],
["AMD Ryzen AI 9 HX PRO 375",12,24,"2GHZ","5.1GHZ","","12 MB","24 MB",28,"AMD Radeon 890M",16,"2900MHZ"],
["AMD Ryzen AI 9 HX PRO 370",12,24,"2GHZ","5.1GHZ","","12 MB","24 MB",28,"AMD Radeon 890M",16,"2900MHZ"],
["AMD Ryzen AI 7 PRO 360",8,16,"2GHZ","5GHZ","","8 MB","16 MB",28,"AMD Radeon 880M",12,"2900MHZ"],
["AMD Ryzen AI 7 PRO 350",8,16,"2GHZ","5GHZ","","8 MB","16 MB",28,"AMD Radeon 860M",8,"3000MHZ"],
["AMD Ryzen AI 5 PRO 340",6,12,"2GHZ","4.8GHZ","","6 MB","16 MB",28,"AMD Radeon 840M",4,"2900MHZ"],
["AMD Ryzen AI Max+ 395",16,32,"3GHZ","5.1GHZ","","16 MB","64 MB",55,"Radeon 8060S Graphics",40,"2900MHZ"],
["AMD Ryzen AI Max 390",12,24,"3.2GHZ","5GHZ","","12 MB","64 MB",55,"Radeon 8050S Graphics",32,"2800MHZ"],
["AMD Ryzen AI Max 385",8,16,"3.6GHZ","5GHZ","","8 MB","32 MB",55,"Radeon 8050S Graphics",32,"2800MHZ"],
["AMD Ryzen AI 9 HX 375",12,24,"2GHZ","5.1GHZ","","12 MB","24 MB",28,"AMD Radeon 890M",16,"2900MHZ"],
["AMD Ryzen Z2 Extreme",8,16,"2GHZ","5GHZ","","8 MB","16 MB",28,"AMD Radeon Graphics",16,""],
["AMD Ryzen Z2",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon Graphics",12,""],
["AMD Ryzen AI 9 HX 370",12,24,"2GHZ","5.1GHZ","","12 MB","24 MB",28,"AMD Radeon 890M",16,"2900MHZ"],
["AMD Ryzen Z2 Go",4,8,"3GHZ","4.3GHZ","","2 MB","8 MB",28,"AMD Radeon Graphics",12,""],
["AMD Ryzen AI 9 365",10,20,"2GHZ","5GHZ","","10 MB","24 MB",28,"AMD Radeon 880M",12,"2900MHZ"],
["AMD Ryzen AI 7 350",8,16,"2GHZ","5GHZ","","8 MB","16 MB",28,"AMD Radeon 860M",8,"3000MHZ"],
["AMD Ryzen AI 5 340",6,12,"2GHZ","4.8GHZ","","6 MB","16 MB",28,"AMD Radeon 840M",4,"2900MHZ"],
["AMD Ryzen 7 PRO 250",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 5 PRO 230",6,12,"3.5GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 PRO 220",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 3 PRO 210",4,8,"3GHZ","4.7GHZ","","4 MB","8 MB",28,"AMD Radeon 740M",4,"2500MHZ"],
["AMD Ryzen 9 270",8,16,"4GHZ","5.2GHZ","","8 MB","16 MB",45,"AMD Radeon 780M",12,"2800MHZ"],
["AMD Ryzen 7 260",8,16,"3.8GHZ","5.1GHZ","","8 MB","16 MB",45,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 250",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 5 240",6,12,"4.3GHZ","5GHZ","","6 MB","16 MB",45,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 230",6,12,"3.5GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 220",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 3 210",4,8,"3GHZ","4.7GHZ","","4 MB","8 MB",28,"AMD Radeon 740M",4,"2500MHZ"],
["AMD Ryzen 9 9955HX3D",16,32,"2.5GHZ","5.4GHZ","1280 KB","16 MB","128 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 9 9950X3D",16,32,"4.3GHZ","5.7GHZ","1280 KB","16 MB","128 MB",170,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 9955HX",16,32,"2.5GHZ","5.4GHZ","1280 KB","16 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 9 9950X",16,32,"4.3GHZ","5.7GHZ","1280 KB","16 MB","64 MB",170,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 9900X3D",12,24,"4.4GHZ","5.5GHZ","960 KB","12 MB","128 MB",120,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 9900X",12,24,"4.4GHZ","5.6GHZ","960 KB","12 MB","64 MB",120,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 9850HX",12,24,"3GHZ","5.2GHZ","960 KB","12 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 7 9800X3D",8,16,"4.7GHZ","5.2GHZ","640 KB","8 MB","96 MB",120,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 7 9700X",8,16,"3.8GHZ","5.5GHZ","640 KB","8 MB","32 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 5 9600X",6,12,"3.9GHZ","5.4GHZ","480 KB","6 MB","32 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 5 9600",6,12,"3.8GHZ","5.2GHZ","480 KB","6 MB","32 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 PRO 8945HS",8,16,"4GHZ","5.2GHZ","","8 MB","16 MB",45,"AMD Radeon 780M",12,"2800MHZ"],
["AMD Ryzen 7 PRO 8840U",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 PRO 8845HS",8,16,"3.8GHZ","5.1GHZ","","8 MB","16 MB",45,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 PRO 8840HS",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 PRO 8700GE",8,16,"3.6GHZ","5.1GHZ","","8 MB","16 MB",35,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 PRO 8700G",8,16,"4.2GHZ","5.1GHZ","","8 MB","16 MB",65,"AMD Radeon 780M",12,"2900MHZ"],
["AMD Ryzen 5 PRO 8640U",6,12,"3.5GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 PRO 8645HS",6,12,"4.3GHZ","5GHZ","","6 MB","16 MB",45,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 PRO 8640HS",6,12,"3.5GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 PRO 8600GE",6,12,"3.9GHZ","5GHZ","","6 MB","16 MB",35,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 PRO 8600G",6,12,"4.3GHZ","5GHZ","","6 MB","16 MB",65,"AMD Radeon 760M",8,"2800MHZ"],
["AMD Ryzen 5 PRO 8540U",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 5 PRO 8500GE",6,12,"3.4GHZ","5GHZ","","6 MB","16 MB",35,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 5 PRO 8500G",6,12,"3.5GHZ","5GHZ","","6 MB","16 MB",65,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 3 PRO 8300GE",4,8,"3.5GHZ","4.9GHZ","","4 MB","8 MB",35,"AMD Radeon 740M",4,"2600MHZ"],
["AMD Ryzen 3 PRO 8300G",4,8,"3.4GHZ","4.9GHZ","","4 MB","8 MB",65,"AMD Radeon 740M",4,"2600MHZ"],
["AMD Ryzen 9 8945HX",16,32,"2.5GHZ","5.4GHZ","1024 KB","16 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 9 8945HS",8,16,"4GHZ","5.2GHZ","","8 MB","16 MB",45,"AMD Radeon 780M",12,"2800MHZ"],
["AMD Ryzen 9 8940HX",16,32,"2.4GHZ","5.3GHZ","1024 KB","16 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 7 8845HS",8,16,"3.8GHZ","5.1GHZ","","8 MB","16 MB",45,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 8840U",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 8840HX",12,24,"2.9GHZ","5.1GHZ","768 KB","12 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 7 8840HS",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 8745HX",8,16,"3.6GHZ","5.1GHZ","512 KB","8 MB","32 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 7 8700G",8,16,"4.2GHZ","5.1GHZ","","8 MB","16 MB",65,"AMD Radeon 780M",12,"2900MHZ"],
["AMD Ryzen 7 8700F",8,16,"4.1GHZ","5GHZ","","8 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 8645HS",6,12,"4.3GHZ","5GHZ","","6 MB","16 MB",45,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 8640U",6,12,"3.5GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 8640HS",6,12,"3.5GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 8600G",6,12,"4.3GHZ","5GHZ","","6 MB","16 MB",65,"AMD Radeon 760M",8,"2800MHZ"],
["AMD Ryzen 5 8540U",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 5 8500GE",6,12,"3.4GHZ","5GHZ","","6 MB","16 MB",35,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 5 8500G",6,12,"3.5GHZ","5GHZ","","6 MB","16 MB",65,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 3 8440U",4,8,"3GHZ","4.7GHZ","","4 MB","8 MB",28,"AMD Radeon 740M",4,"2500MHZ"],
["AMD Ryzen 3 8300GE",4,8,"3.5GHZ","4.9GHZ","","4 MB","8 MB",35,"AMD Radeon 740M",4,"2600MHZ"],
["AMD Ryzen 5 8400F",6,12,"4.2GHZ","4.7GHZ","","6 MB","16 MB",65,"",0,""],
["AMD Ryzen 3 8300G",4,8,"3.4GHZ","4.9GHZ","","4 MB","8 MB",65,"AMD Radeon 740M",4,"2600MHZ"],
["AMD Ryzen Threadripper PRO 7995WX",96,192,"2.5GHZ","5.1GHZ","6144 KB","96 MB","384 MB",350,"",0,""],
["AMD Ryzen Threadripper PRO 7985WX",64,128,"3.2GHZ","5.1GHZ","4096 KB","64 MB","256 MB",350,"",0,""],
["AMD Ryzen Threadripper PRO 7975WX",32,64,"4GHZ","5.3GHZ","2048 KB","32 MB","128 MB",350,"",0,""],
["AMD Ryzen Threadripper PRO 7965WX",24,48,"4.2GHZ","5.3GHZ","1536 KB","24 MB","128 MB",350,"",0,""],
["AMD Ryzen Threadripper PRO 7955WX",16,32,"4.5GHZ","5.3GHZ","1024 KB","16 MB","64 MB",350,"",0,""],
["AMD Ryzen Threadripper PRO 7945WX",12,24,"4.7GHZ","5.3GHZ","768 KB","12 MB","64 MB",350,"",0,""],
["AMD Ryzen Threadripper 7980X",64,128,"3.2GHZ","5.1GHZ","4096 KB","64 MB","256 MB",350,"",0,""],
["AMD Ryzen Threadripper 7970X",32,64,"4GHZ","5.3GHZ","2048 KB","32 MB","128 MB",350,"",0,""],
["AMD Ryzen Threadripper 7960X",24,48,"4.2GHZ","5.3GHZ","1536 KB","24 MB","128 MB",350,"",0,""],
["AMD Ryzen 9 PRO 7945",12,24,"3.7GHZ","5.4GHZ","768 KB","12 MB","64 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 PRO 7940HS",8,16,"4GHZ","5.2GHZ","","8 MB","16 MB",0,"AMD Radeon 780M",12,"2800MHZ"],
["AMD Ryzen 7 PRO 7840U",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",0,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 PRO 7840HS",8,16,"3.8GHZ","5.1GHZ","","8 MB","16 MB",0,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 PRO 7745",8,16,"3.8GHZ","5.3GHZ","512 KB","8 MB","32 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 7 PRO 7735U",8,16,"2.7GHZ","4.75GHZ","512 KB","4 MB","16 MB",0,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 PRO 7730U",8,16,"2GHZ","4.5GHZ","512 KB","4 MB","16 MB",15,"AMD Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 5 PRO 7645",6,12,"3.8GHZ","5.1GHZ","384 KB","6 MB","32 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 5 PRO 7640U",6,12,"3.5GHZ","4.9GHZ","","6 MB","16 MB",0,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 PRO 7640HS",6,12,"4.3GHZ","5GHZ","","6 MB","16 MB",0,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 PRO 7545U",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",0,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 5 PRO 7540U",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",0,"AMD Radeon 740M",4,"2500MHZ"],
["AMD Ryzen 5 PRO 7535U",6,12,"2.9GHZ","4.55GHZ","384 KB","3 MB","16 MB",0,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen 5 PRO 7530U",6,12,"2GHZ","4.5GHZ","384 KB","3 MB","16 MB",15,"AMD Radeon Graphics",7,"2000MHZ"],
["AMD Ryzen 3 PRO 7335U",4,8,"3GHZ","4.3GHZ","2048 KB","8 MB","",0,"AMD Radeon 660M",4,"1800MHZ"],
["AMD Ryzen 3 PRO 7330U",4,8,"2.3GHZ","4.3GHZ","256 KB","2 MB","8 MB",15,"AMD Radeon Graphics",6,"1800MHZ"],
["AMD Ryzen 9 7950X3D",16,32,"4.2GHZ","5.7GHZ","1024 KB","16 MB","128 MB",120,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 7950X",16,32,"4.5GHZ","5.7GHZ","1024 KB","16 MB","64 MB",170,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 7945HX3D",16,32,"2.3GHZ","5.4GHZ","1024 KB","16 MB","128 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 9 7945HX",16,32,"2.5GHZ","5.4GHZ","1024 KB","16 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 9 7940HS",8,16,"4GHZ","5.2GHZ","512 KB","8 MB","16 MB",35-54,"AMD Radeon 780M",12,"2800MHZ"],
["AMD Ryzen 9 7940HX",16,32,"2.4GHZ","5.2GHZ","1024 KB","16 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 9 7900X3D",12,24,"4.4GHZ","5.6GHZ","768 KB","12 MB","128 MB",120,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 7900X",12,24,"4.7GHZ","5.6GHZ","768 KB","12 MB","64 MB",170,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 7900",12,24,"3.7GHZ","5.4GHZ","768 KB","12 MB","64 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 9 7845HX",12,24,"3GHZ","5.2GHZ","764 KB","12 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 7 7840U",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 7840HX",12,24,"2.9GHZ","5.1GHZ","768 KB","12 MB","64 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 7 7840HS",8,16,"3.8GHZ","5.1GHZ","512 KB","8 MB","16 MB",35-54,"AMD Radeon 780M",12,"2700MHZ"],
["AMD Ryzen 7 7800X3D",8,16,"4.2GHZ","5GHZ","512 KB","8 MB","96 MB",120,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 7 7745HX",8,16,"3.6GHZ","5.1GHZ","512 KB","8 MB","32 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 7 7736U",8,16,"2.7GHZ","4.7GHZ","512 KB","4 MB","16 MB",0,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 7735U",8,16,"2.7GHZ","4.75GHZ","512 KB","4 MB","16 MB",28,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 7735HS",8,16,"3.2GHZ","4.75GHZ","512 KB","4 MB","16 MB",35-54,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 7730U",8,16,"2GHZ","4.5GHZ","512 KB","4 MB","16 MB",15,"AMD Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 7700X",8,16,"4.5GHZ","5.4GHZ","512 KB","8 MB","32 MB",105,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 7 7700",8,16,"3.8GHZ","5.3GHZ","512 KB","8 MB","32 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 5 7645HX",6,12,"4GHZ","5GHZ","384 KB","6 MB","32 MB",55,"AMD Radeon 610M",2,"2200MHZ"],
["AMD Ryzen 5 7640U",6,12,"3.5GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 7640HS",6,12,"4.3GHZ","5GHZ","384 KB","6 MB","16 MB",35-54,"AMD Radeon 760M",8,"2600MHZ"],
["AMD Ryzen 5 7600X3D",6,12,"4.1GHZ","4.7GHZ","384 KB","6 MB","96 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 5 7600X",6,12,"4.7GHZ","5.3GHZ","384 KB","6 MB","32 MB",105,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 5 7600",6,12,"3.8GHZ","5.1GHZ","384 KB","6 MB","32 MB",65,"AMD Radeon Graphics",2,"2200MHZ"],
["AMD Ryzen 5 7545U",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 740M",4,"2800MHZ"],
["AMD Ryzen 5 7540U",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon 740M",4,"2500MHZ"],
["AMD Ryzen 5 7535U",6,12,"2.9GHZ","4.55GHZ","512 KB","3 MB","16 MB",28,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen 5 7535HS",6,12,"3.3GHZ","4.55GHZ","512 KB","3 MB","16 MB",35-54,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen 5 7533HS",6,12,"3.3GHZ","4.4GHZ","512 KB","3 MB","16 MB",35-54,"AMD Radeon 660M",6,"1800MHZ"],
["AMD Ryzen 5 7530U",6,12,"2GHZ","4.5GHZ","384 KB","3 MB","16 MB",15,"AMD Radeon Graphics",7,"2000MHZ"],
["AMD Ryzen 5 7520U",4,8,"2.8GHZ","4.3GHZ","256 KB","2 MB","4 MB",15,"AMD Radeon 610M",2,"1900MHZ"],
["AMD Ryzen 5 7520C",4,8,"2.8GHZ","4.3GHZ","256 KB","2 MB","4 MB",15,"AMD Radeon 610M",2,"1900MHZ"],
["AMD Ryzen 5 7500F",6,12,"3.7GHZ","5GHZ","384 KB","6 MB","32 MB",65,"",0,""],
["AMD Ryzen 3 7440U",4,8,"3GHZ","4.7GHZ","","4 MB","8 MB",28,"AMD Radeon 740M",4,"2500MHZ"],
["AMD Ryzen 7 7435HS",8,16,"3.1GHZ","4.5GHZ","512 KB","4 MB","16 MB",45,"",0,""],
["AMD Ryzen 5 7430U",6,12,"2.3GHZ","4.3GHZ","384 KB","3 MB","16 MB",15,"AMD Radeon Graphics",7,"1800MHZ"],
["AMD Ryzen 5 7400F",6,12,"3.7GHZ","4.7GHZ","384 KB","6 MB","32 MB",65,"",0,""],
["AMD Ryzen 3 7335U",4,8,"3GHZ","4.3GHZ","512 KB","2 MB","8 MB",28,"AMD Radeon 660M",4,"1800MHZ"],
["AMD Ryzen 3 7330U",4,8,"2.3GHZ","4.3GHZ","256 KB","2 MB","8 MB",15,"AMD Radeon Graphics",6,"1800MHZ"],
["AMD Ryzen 3 7320U",4,8,"2.4GHZ","4.1GHZ","256 KB","2 MB","4 MB",15,"AMD Radeon 610M",2,"1900MHZ"],
["AMD Ryzen 3 7320C",4,8,"2.4GHZ","4.1GHZ","256 KB","2 MB","4 MB",15,"AMD Radeon 610M",2,"1900MHZ"],
["AMD Ryzen 5 7235HS",4,8,"3.2GHZ","4.2GHZ","384 KB","2 MB","8 MB",45,"",0,""],
["AMD Ryzen Z1 Extreme",8,16,"3.3GHZ","5.1GHZ","","8 MB","16 MB",28,"AMD Radeon Graphics",12,""],
["AMD Ryzen Z1",6,12,"3.2GHZ","4.9GHZ","","6 MB","16 MB",28,"AMD Radeon Graphics",4,""],
["AMD Athlon Gold 7220U",2,4,"2.4GHZ","3.7GHZ","256 KB","1 MB","4 MB",15,"AMD Radeon 610M",2,"1900MHZ"],
["AMD Athlon Gold 7220C",2,4,"2.4GHZ","3.7GHZ","256 KB","1 MB","2 MB",15,"AMD Radeon 610M",2,"1900MHZ"],
["AMD Athlon Silver 7120U",2,2,"2.4GHZ","3.5GHZ","256 KB","1 MB","2 MB",15,"AMD Radeon 610M",2,"1900MHZ"],
["AMD Athlon Silver 7120C",2,2,"2.4GHZ","3.5GHZ","256 KB","1 MB","2 MB",15,"AMD Radeon 610M",2,"1900MHZ"],
["AMD Ryzen 9 PRO 6950HS",8,16,"3.3GHZ","4.9GHZ","512 KB","4 MB","16 MB",35,"AMD Radeon 680M",12,"2400MHZ"],
["AMD Ryzen 9 PRO 6950H",8,16,"3.3GHZ","4.9GHZ","384 KB","4 MB","16 MB",45,"AMD Radeon 680M",12,"2400MHZ"],
["AMD Ryzen 7 PRO 6860Z",8,16,"2.7GHZ","4.75GHZ","512 KB","4 MB","16 MB",28,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 PRO 6850U",8,16,"2.7GHZ","4.7GHZ","512 KB","4 MB","16 MB",0,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 PRO 6850HS",8,16,"3.2GHZ","4.7GHZ","512 KB","4 MB","16 MB",35,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 PRO 6850H",8,16,"3.2GHZ","4.7GHZ","512 KB","4 MB","16 MB",45,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 5 PRO 6650U",6,12,"2.9GHZ","4.5GHZ","384 KB","3 MB","16 MB",0,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen 5 PRO 6650HS",6,12,"3.3GHZ","4.5GHZ","384 KB","3 MB","16 MB",35,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen 5 PRO 6650H",6,12,"3.3GHZ","4.5GHZ","384 KB","3 MB","16 MB",45,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen 9 6980HX",8,16,"3.3GHZ","5GHZ","512 KB","4 MB","16 MB",45,"AMD Radeon 680M",12,"2400MHZ"],
["AMD Ryzen 9 6980HS",8,16,"3.3GHZ","5GHZ","512 KB","4 MB","16 MB",35,"AMD Radeon 680M",12,"2400MHZ"],
["AMD Ryzen 9 6900HX",8,16,"3.3GHZ","4.9GHZ","512 KB","4 MB","16 MB",45,"AMD Radeon 680M",12,"2400MHZ"],
["AMD Ryzen 9 6900HS",8,16,"3.3GHZ","4.9GHZ","512 KB","4 MB","16 MB",35,"AMD Radeon 680M",12,"2400MHZ"],
["AMD Ryzen 7 6800U",8,16,"2.7GHZ","4.7GHZ","512 KB","4 MB","16 MB",0,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 6800HS",8,16,"3.2GHZ","4.7GHZ","512 KB","4 MB","16 MB",35,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 7 6800H",8,16,"3.2GHZ","4.7GHZ","512 KB","4 MB","16 MB",45,"AMD Radeon 680M",12,"2200MHZ"],
["AMD Ryzen 5 6600U",6,12,"2.9GHZ","4.5GHZ","384 KB","3 MB","16 MB",0,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen 5 6600HS",6,12,"3.3GHZ","4.5GHZ","384 KB","3 MB","16 MB",35,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen 5 6600H",6,12,"3.3GHZ","4.5GHZ","384 KB","3 MB","16 MB",45,"AMD Radeon 660M",6,"1900MHZ"],
["AMD Ryzen Threadripper PRO 5995WX",64,128,"2.7GHZ","4.5GHZ","4096 KB","32 MB","256 MB",280,"",0,""],
["AMD Ryzen Threadripper PRO 5975WX",32,64,"3.6GHZ","4.5GHZ","2048 KB","16 MB","128 MB",280,"",0,""],
["AMD Ryzen Threadripper PRO 5965WX",24,48,"3.8GHZ","4.5GHZ","1536 KB","12 MB","128 MB",280,"",0,""],
["AMD Ryzen Threadripper PRO 5955WX",16,32,"4GHZ","4.5GHZ","1024 KB","8 MB","64 MB",280,"",0,""],
["AMD Ryzen Threadripper PRO 5945WX",12,24,"4.1GHZ","4.5GHZ","765 KB","6 MB","64 MB",280,"",0,""],
["AMD Ryzen 9 PRO 5945",12,24,"3GHZ","4.7GHZ","768 KB","6 MB","64 MB",65,"",0,""],
["AMD Ryzen 7 PRO 5875U",8,16,"2GHZ","4.5GHZ","512 KB","4 MB","16 MB",15,"AMD Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 PRO 5850U",8,16,"1.9GHZ","4.4GHZ","","4 MB","16 MB",15,"AMD Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 PRO 5845",8,16,"3.4GHZ","4.6GHZ","512 KB","4 MB","32 MB",65,"",0,""],
["AMD Ryzen 7 PRO 5755GE",8,16,"3.2GHZ","4.6GHZ","","4 MB","16 MB",35,"Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 PRO 5755G",8,16,"3.8GHZ","4.6GHZ","","4 MB","16 MB",65,"Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 PRO 5750GE",8,16,"3.2GHZ","4.6GHZ","","4 MB","16 MB",35,"Radeon  Graphics",8,"2000MHZ"],
["AMD Ryzen 7 PRO 5750G",8,16,"3.8GHZ","4.6GHZ","","4 MB","16 MB",65,"Radeon  Graphics",8,"2000MHZ"],
["AMD Ryzen 5 PRO 5675U",6,12,"2.3GHZ","4.3GHZ","384 KB","3 MB","16 MB",15,"AMD Radeon Graphics",7,"1800MHZ"],
["AMD Ryzen 5 PRO 5655GE",6,12,"3.4GHZ","4.4GHZ","","3 MB","16 MB",35,"Radeon  Graphics",7,"1900MHZ"],
["AMD Ryzen 5 PRO 5655G",6,12,"3.9GHZ","4.4GHZ","","3 MB","16 MB",65,"Radeon  Graphics",7,"1900MHZ"],
["AMD Ryzen 5 PRO 5650U",6,12,"2.3GHZ","4.2GHZ","","3 MB","16 MB",15,"AMD Radeon Graphics",7,"1800MHZ"],
["AMD Ryzen 5 PRO 5650GE",6,12,"3.4GHZ","4.4GHZ","","3 MB","16 MB",35,"Radeon  Graphics",7,"1900MHZ"],
["AMD Ryzen 5 PRO 5650G",6,12,"3.9GHZ","4.4GHZ","","3 MB","16 MB",65,"Radeon  Graphics",7,"1900MHZ"],
["AMD Ryzen 5 PRO 5645",6,12,"3.7GHZ","4.6GHZ","768 KB","3 MB","32 MB",65,"",0,""],
["AMD Ryzen 3 PRO 5475U",4,8,"2.7GHZ","4.1GHZ","256 KB","2 MB","8 MB",15,"AMD Radeon Graphics",6,"1600MHZ"],
["AMD Ryzen 3 PRO 5450U",4,8,"2.6GHZ","4GHZ","","2 MB","8 MB",15,"AMD Radeon Graphics",6,"1600MHZ"],
["AMD Ryzen 3 PRO 5355GE",4,8,"3.6GHZ","4.2GHZ","","2 MB","8 MB",35,"Radeon  Graphics",6,"1700MHZ"],
["AMD Ryzen 3 PRO 5355G",4,8,"4GHZ","4.2GHZ","","2 MB","8 MB",65,"Radeon  Graphics",6,"1700MHZ"],
["AMD Ryzen 3 PRO 5350GE",4,8,"3.6GHZ","4.2GHZ","","2 MB","8 MB",35,"Radeon  Graphics",6,"1700MHZ"],
["AMD Ryzen 3 PRO 5350G",4,8,"4GHZ","4.2GHZ","","2 MB","8 MB",65,"Radeon  Graphics",6,"1700MHZ"],
["AMD Ryzen 9 5980HX",8,16,"3.3GHZ","4.8GHZ","","4 MB","16 MB",45,"AMD Radeon Graphics",8,"2100MHZ"],
["AMD Ryzen 9 5980HS",8,16,"3GHZ","4.8GHZ","","4 MB","16 MB",35,"AMD Radeon Graphics",8,"2100MHZ"],
["AMD Ryzen 9 5950X",16,32,"3.4GHZ","4.9GHZ","","8 MB","64 MB",105,"",0,""],
["AMD Ryzen 9 5900XT",16,32,"3.3GHZ","4.8GHZ","1024 KB","8 MB","64 MB",105,"",0,""],
["AMD Ryzen 9 5900X",12,24,"3.7GHZ","4.8GHZ","","6 MB","64 MB",105,"",0,""],
["AMD Ryzen 9 5900HX",8,16,"3.3GHZ","4.6GHZ","","4 MB","16 MB",45,"AMD Radeon Graphics",8,"2100MHZ"],
["AMD Ryzen 9 5900HS",8,16,"3GHZ","4.6GHZ","","4 MB","16 MB",35,"AMD Radeon Graphics",0,"2100MHZ"],
["AMD Ryzen 9 5900",12,24,"3GHZ","4.7GHZ","","6 MB","64 MB",65,"",0,""],
["AMD Ryzen 7 5825U",8,16,"2GHZ","4.5GHZ","512 KB","4 MB","16 MB",15,"AMD Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 5825C",8,16,"2GHZ","4.5GHZ","512 KB","4 MB","16 MB",15,"AMD Radeon Graphics",8,""],
["AMD Ryzen 7 5800X3D",8,16,"3.4GHZ","4.5GHZ","512 KB","4 MB","96 MB",105,"",0,""],
["AMD Ryzen 7 5800XT",8,16,"3.8GHZ","4.8GHZ","512 KB","4 MB","32 MB",105,"",0,""],
["AMD Ryzen 7 5800X",8,16,"3.8GHZ","4.7GHZ","","4 MB","32 MB",105,"",0,""],
["AMD Ryzen 7 5800U",8,16,"1.9GHZ","4.4GHZ","","4 MB","16 MB",15,"AMD Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 5800HS",8,16,"2.8GHZ","4.4GHZ","","4 MB","16 MB",35,"AMD Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 5800H",8,16,"3.2GHZ","4.4GHZ","","4 MB","16 MB",45,"AMD Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 5800",8,16,"3.4GHZ","4.6GHZ","","4 MB","32 MB",65,"",0,""],
["AMD Ryzen 7 5705GE",8,16,"3.2GHZ","4.6GHZ","","4 MB","16 MB",35,"Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 5705G",8,16,"3.8GHZ","4.6GHZ","","4 MB","16 MB",65,"Radeon Graphics",8,"2000MHZ"],
["AMD Ryzen 7 5700X3D",8,16,"3GHZ","4.1GHZ","512 KB","4 MB","96 MB",105,"",0,""],
["AMD Ryzen 7 5700X",8,16,"3.4GHZ","4.6GHZ","512 KB","4 MB","32 MB",65,"",0,""],
["AMD Ryzen 7 5700U",8,16,"1.8GHZ","4.3GHZ","","4 MB","8 MB",15,"AMD Radeon Graphics",8,"1900MHZ"],
["AMD Ryzen 7 5700GE",8,16,"3.2GHZ","4.6GHZ","","4 MB","16 MB",35,"Radeon  Graphics",8,"2000MHZ"],
["AMD Ryzen 7 5700G",8,16,"3.8GHZ","4.6GHZ","","4 MB","16 MB",65,"Radeon  Graphics",8,"2000MHZ"],
["AMD Ryzen 7 5700",8,16,"3.7GHZ","4.6GHZ","512 KB","4 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 5625U",6,12,"2.3GHZ","4.3GHZ","384 KB","3 MB","16 MB",15,"AMD Radeon Graphics",7,"1800MHZ"],
["AMD Ryzen 5 5625C",6,12,"2.3GHZ","4.3GHZ","384 KB","3 MB","16 MB",15,"AMD Radeon Graphics",7,""],
["AMD Ryzen 5 5605GE",6,12,"3.4GHZ","4.4GHZ","","3 MB","16 MB",35,"Radeon Graphics",7,"1900MHZ"],
["AMD Ryzen 5 5605G",6,12,"3.9GHZ","4.4GHZ","","3 MB","16 MB",65,"Radeon Graphics",7,"1900MHZ"],
["AMD Ryzen 5 5600X3D",6,12,"3.3GHZ","4.4GHZ","384 KB","3 MB","96 MB",105,"",0,""],
["AMD Ryzen 5 5600X",6,12,"3.7GHZ","4.6GHZ","","3 MB","32 MB",65,"",0,""],
["AMD Ryzen 5 5600U",6,12,"2.3GHZ","4.2GHZ","","3 MB","16 MB",15,"AMD Radeon Graphics",7,"1800MHZ"],
["AMD Ryzen 5 5600HS",6,12,"3GHZ","4.2GHZ","","3 MB","16 MB",35,"AMD Radeon Graphics",7,"1800MHZ"],
["AMD Ryzen 5 5600H",6,12,"3.3GHZ","4.2GHZ","","3 MB","16 MB",45,"AMD Radeon Graphics",7,"1800MHZ"],
["AMD Ryzen 5 5600XT",6,12,"3.7GHZ","4.7GHZ","384 KB","3 MB","32 MB",65,"",0,""],
["AMD Ryzen 5 5600T",6,12,"3.5GHZ","4.5GHZ","384 KB","3 MB","32 MB",65,"",0,""],
["AMD Ryzen 5 5600GT",6,12,"3.6GHZ","4.6GHZ","384 KB","3 MB","16 MB",65,"Radeon Graphics",7,"1900MHZ"],
["AMD Ryzen 5 5600GE",6,12,"3.4GHZ","4.4GHZ","","3 MB","16 MB",35,"Radeon  Graphics",7,"1900MHZ"],
["AMD Ryzen 5 5600G",6,12,"3.9GHZ","4.4GHZ","","3 MB","16 MB",65,"Radeon  Graphics",7,"1900MHZ"],
["AMD Ryzen 5 5600",6,12,"3.5GHZ","4.4GHZ","384 KB","3 MB","32 MB",65,"",0,""],
["AMD Ryzen 5 5560U",6,12,"2.3GHZ","4GHZ","384 KB","3 MB","8 MB",15,"AMD Radeon  Graphics",6,"1600MHZ"],
["AMD Ryzen 5 5500U",6,12,"2.1GHZ","4GHZ","","3 MB","8 MB",15,"AMD Radeon Graphics",7,"1800MHZ"],
["AMD Ryzen 5 5500H",4,8,"3.3GHZ","4.2GHZ","","2 MB","8 MB",45,"AMD Radeon Graphics",6,"1800MHZ"],
["AMD Ryzen 5 5500GT",6,12,"3.6GHZ","4.4GHZ","384 KB","3 MB","16 MB",65,"Radeon Graphics",7,"1900MHZ"],
["AMD Ryzen 5 5500",6,12,"3.6GHZ","4.2GHZ","384 KB","3 MB","16 MB",65,"",0,""],
["AMD Ryzen 3 5425U",4,8,"2.7GHZ","4.1GHZ","256 KB","2 MB","8 MB",15,"AMD Radeon Graphics",6,"1600MHZ"],
["AMD Ryzen 3 5425C",4,8,"2.7GHZ","4.1GHZ","256 KB","2 MB","8 MB",15,"AMD Radeon Graphics",6,""],
["AMD Ryzen 3 5400U",4,8,"2.6GHZ","4GHZ","","2 MB","8 MB",15,"AMD Radeon Graphics",6,"1600MHZ"],
["AMD Ryzen 3 5305GE",4,8,"3.6GHZ","4.2GHZ","","2 MB","8 MB",35,"Radeon Graphics",6,"1700MHZ"],
["AMD Ryzen 3 5305G",4,8,"4GHZ","4.2GHZ","","2 MB","8 MB",65,"Radeon Graphics",6,"1700MHZ"],
["AMD Ryzen 3 5300U",4,8,"2.6GHZ","3.8GHZ","","2 MB","4 MB",15,"AMD Radeon Graphics",6,"1500MHZ"],
["AMD Ryzen 3 5300GE",4,8,"3.6GHZ","4.2GHZ","","2 MB","8 MB",35,"Radeon  Graphics",6,"1700MHZ"],
["AMD Ryzen 3 5300G",4,8,"4GHZ","4.2GHZ","","2 MB","8 MB",65,"Radeon  Graphics",6,"1700MHZ"],
["AMD Ryzen 3 5125C",2,4,"3GHZ","3GHZ","128 KB","1 MB","8 MB",15,"AMD Radeon Graphics",3,""],
["AMD Ryzen 7 PRO 4750U",8,16,"1.7GHZ","4.1GHZ","","4 MB","8 MB",15,"AMD Radeon Graphics",7,"1600MHZ"],
["AMD Ryzen 7 PRO 4750GE",8,16,"3.1GHZ","4.3GHZ","512 KB","4 MB","8 MB",35,"Radeon Graphics",8,"2100MHZ"],
["AMD Ryzen 7 PRO 4750G",8,16,"3.6GHZ","4.4GHZ","512 KB","4 MB","8 MB",65,"Radeon Graphics",8,"2100MHZ"],
["AMD Ryzen 5 PRO 4655GE",6,12,"3.3GHZ","4.2GHZ","384 KB","3 MB","8 MB",35,"Radeon Graphics",7,"1900MHZ"],
["AMD Ryzen 5 PRO 4655G",6,12,"3.7GHZ","4.2GHZ","384 KB","3 MB","8 MB",65,"Radeon Graphics",7,"1900MHZ"],
["AMD Ryzen 5 PRO 4650U",6,12,"2.1GHZ","4GHZ","","3 MB","8 MB",15,"AMD Radeon Graphics",6,"1500MHZ"],
["AMD Ryzen 5 PRO 4650GE",6,12,"3.3GHZ","4.2GHZ","384 KB","3 MB","8 MB",35,"Radeon Graphics",7,"1900MHZ"],
["AMD Ryzen 5 PRO 4650G",6,12,"3.7GHZ","4.2GHZ","384 KB","3 MB","8 MB",65,"Radeon Graphics",7,"1900MHZ"],
["AMD Ryzen 3 PRO 4450U",4,8,"2.5GHZ","3.7GHZ","","2 MB","4 MB",15,"AMD Radeon Graphics",5,"1400MHZ"],
["AMD Ryzen 3 PRO 4355GE",4,8,"3.5GHZ","4GHZ","256 KB","2 MB","4 MB",35,"Radeon Vega 6 Graphics",6,"1700MHZ"],
["AMD Ryzen 3 PRO 4355G",4,8,"3.8GHZ","4GHZ","256 KB","2 MB","4 MB",65,"Radeon Graphics",6,"1700MHZ"],
["AMD Ryzen 3 PRO 4350GE",4,8,"3.5GHZ","4GHZ","256 KB","2 MB","4 MB",35,"Radeon Vega 6 Graphics",6,"1700MHZ"],
["AMD Ryzen 3 PRO 4350G",4,8,"3.8GHZ","4GHZ","256 KB","2 MB","4 MB",65,"Radeon Graphics",6,"1700MHZ"],
["AMD Ryzen 9 4900HS",8,16,"3GHZ","4.3GHZ","","4 MB","8 MB",35,"AMD Radeon Graphics",8,"1750MHZ"],
["AMD Ryzen 9 4900H",8,16,"3.3GHZ","4.4GHZ","","4 MB","8 MB",35-54,"AMD Radeon Graphics",8,"1750MHZ"],
["AMD Ryzen 7 4980U Microsoft Surface® Edition",8,16,"2GHZ","4.4GHZ","512 KB","4 MB","8 MB",15,"Radeon  Graphics",8,"1950MHZ"],
["AMD Ryzen 7 4800U",8,16,"1.8GHZ","4.2GHZ","","4 MB","8 MB",15,"AMD Radeon Graphics",8,"1750MHZ"],
["AMD Ryzen 7 4800HS",8,16,"2.9GHZ","4.2GHZ","","4 MB","8 MB",45,"AMD Radeon Graphics",7,"1600MHZ"],
["AMD Ryzen 7 4800H",8,16,"2.9GHZ","4.2GHZ","","4 MB","8 MB",45,"AMD Radeon Graphics",7,"1600MHZ"],
["AMD Ryzen 7 4700U",8,8,"2GHZ","4.1GHZ","","4 MB","8 MB",15,"AMD Radeon Graphics",7,"1600MHZ"],
["AMD Ryzen 7 4700GE",8,16,"3.1GHZ","4.3GHZ","512 KB","4 MB","8 MB",35,"Radeon  Graphics",8,"2000MHZ"],
["AMD Ryzen 7 4700G",8,16,"3.6GHZ","4.4GHZ","512 KB","4 MB","8 MB",65,"Radeon Graphics",8,"2100MHZ"],
["AMD Ryzen 5 4680U Microsoft Surface® Edition",6,12,"2.2GHZ","4GHZ","384 KB","3 MB","8 MB",15,"Radeon  Graphics",7,"1500MHZ"],
["AMD Ryzen 5 4600U",6,12,"2.1GHZ","4GHZ","","3 MB","8 MB",15,"AMD Radeon Graphics",6,"1500MHZ"],
["AMD Ryzen 5 4600H",6,12,"3GHZ","4GHZ","","3 MB","8 MB",45,"AMD Radeon Graphics",6,"1500MHZ"],
["AMD Ryzen 5 4600GE",6,12,"3.3GHZ","4.2GHZ","384 KB","3 MB","8 MB",35,"Radeon  Graphics",7,"1900MHZ"],
["AMD Ryzen 5 4600G",6,12,"3.7GHZ","4.2GHZ","384 KB","3 MB","8 MB",65,"Radeon  Graphics",7,"1900MHZ"],
["AMD Ryzen 5 4500U",6,6,"2.3GHZ","4GHZ","","3 MB","8 MB",15,"AMD Radeon Graphics",6,"1500MHZ"],
["AMD Ryzen 5 4500",6,12,"3.6GHZ","4.1GHZ","384 KB","3 MB","8 MB",65,"",0,""],
["AMD Ryzen 3 4300U",4,4,"2.7GHZ","3.7GHZ","","2 MB","4 MB",15,"AMD Radeon Graphics",5,"1400MHZ"],
["AMD Ryzen 3 4300GE",4,8,"3.5GHZ","4GHZ","256 KB","2 MB","4 MB",35,"Radeon  Graphics",6,"1700MHZ"],
["AMD Ryzen 3 4300G",4,8,"3.8GHZ","4GHZ","256 KB","2 MB","4 MB",65,"Radeon  Graphics",6,"1700MHZ"],
["AMD Ryzen 3 4100",4,8,"3.8GHZ","4GHZ","256 KB","2 MB","4 MB",65,"",0,""],
["AMD Ryzen Threadripper PRO 3995WX",64,128,"2.7GHZ","4.2GHZ","4096 KB","32 MB","256 MB",280,"",0,""],
["AMD Ryzen Threadripper PRO 3975WX",32,64,"3.5GHZ","4.2GHZ","2048 KB","16 MB","128 MB",280,"",0,""],
["AMD Ryzen Threadripper PRO 3955WX",16,32,"3.9GHZ","4.3GHZ","1024 KB","8 MB","64 MB",280,"",0,""],
["AMD Ryzen Threadripper PRO 3945WX",12,24,"4GHZ","4.3GHZ","768 KB","6 MB","64 MB",280,"",0,""],
["AMD Ryzen Threadripper 3990X",64,128,"2.9GHZ","4.3GHZ","4096 KB","32 MB","256 MB",280,"",0,""],
["AMD Ryzen Threadripper 3970X",32,64,"3.7GHZ","4.5GHZ","2048 KB","16 MB","128 MB",280,"",0,""],
["AMD Ryzen Threadripper 3960X",24,48,"3.8GHZ","4.5GHZ","1536 KB","12 MB","128 MB",280,"",0,""],
["AMD Ryzen 9 PRO 3900",12,24,"3.1GHZ","4.3GHZ","768 KB","6 MB","64 MB",65,"",0,""],
["AMD Ryzen 7 PRO 3700U",4,8,"2.3GHZ","4GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 10 Graphics",10,"1400MHZ"],
["AMD Ryzen 7 PRO 3700",8,16,"3.6GHZ","4.4GHZ","512 KB","4 MB","32 MB",65,"",0,""],
["AMD Ryzen 5 PRO 3600",6,12,"3.6GHZ","4.2GHZ","384 KB","3 MB","32 MB",65,"",0,""],
["AMD Ryzen 5 PRO 3500U",4,8,"2.1GHZ","3.7GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 8 Graphics",8,"1200MHZ"],
["AMD Ryzen 5 PRO 3400GE",4,8,"3.3GHZ","4GHZ","384 KB","2 MB","4 MB",35,"Radeon Vega 11 Graphics",11,"1300MHZ"],
["AMD Ryzen 5 PRO 3400G",4,8,"3.7GHZ","4.2GHZ","384 KB","2 MB","4 MB",65,"Radeon Vega 11 Graphics",11,"1400MHZ"],
["AMD Ryzen 5 PRO 3350GE",4,4,"3.3GHZ","3.9GHZ","384 KB","2 MB","4 MB",35,"Radeon  Graphics",10,"1200MHZ"],
["AMD Ryzen 5 PRO 3350G",4,8,"3.6GHZ","4GHZ","384 KB","2 MB","4 MB",65,"Radeon  Graphics",10,"1300MHZ"],
["AMD Ryzen 3 PRO 3300U",4,4,"2.1GHZ","3.5GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 6 Graphics",6,"1200MHZ"],
["AMD Ryzen 3 PRO 3200GE",4,4,"3.3GHZ","3.8GHZ","384 KB","2 MB","4 MB",35,"Radeon Vega 8 Graphics",8,"1200MHZ"],
["AMD Ryzen 3 PRO 3200G",4,4,"3.6GHZ","4GHZ","384 KB","2 MB","4 MB",65,"Radeon Vega 8 Graphics",8,"1250MHZ"],
["AMD Ryzen 9 3950X",16,32,"3.5GHZ","4.7GHZ","1024 KB","8 MB","64 MB",105,"",0,""],
["AMD Ryzen 9 3900XT",12,24,"3.8GHZ","4.7GHZ","","6 MB","64 MB",105,"",0,""],
["AMD Ryzen 9 3900X",12,24,"3.8GHZ","4.6GHZ","768 KB","6 MB","64 MB",105,"",0,""],
["AMD Ryzen 9 3900 Processor",12,24,"3.1GHZ","4.3GHZ","768 KB","6 MB","64 MB",65,"",0,""],
["AMD Ryzen 7 3800XT",8,16,"3.9GHZ","4.7GHZ","","4 MB","32 MB",105,"",0,""],
["AMD Ryzen 7 3800X",8,16,"3.9GHZ","4.5GHZ","512 KB","4 MB","32 MB",105,"",0,""],
["AMD Ryzen 7 3780U Microsoft Surface® Edition",4,8,"2.3GHZ","4GHZ","384 KB","2 MB","4 MB",15,"Radeon RX Vega 11 Graphics",11,"1400MHZ"],
["AMD Ryzen 7 3750H",4,8,"2.3GHZ","4GHZ","384 KB","2 MB","4 MB",35,"Radeon RX Vega 10 Graphics",10,"1400MHZ"],
["AMD Ryzen 7 3700X",8,16,"3.6GHZ","4.4GHZ","512 KB","4 MB","32 MB",65,"",0,""],
["AMD Ryzen 7 3700U",4,8,"2.3GHZ","4GHZ","384 KB","2 MB","4 MB",15,"Radeon RX Vega 10 Graphics",10,"1400MHZ"],
["AMD Ryzen 7 3700C",4,8,"2.3GHZ","4GHZ","384 KB","2 MB","4 MB",15,"AMD Radeon Graphics",10,"1400MHZ"],
["AMD Ryzen 5 3600XT",6,12,"3.8GHZ","4.5GHZ","","3 MB","32 MB",95,"",0,""],
["AMD Ryzen 5 3600X",6,12,"3.8GHZ","4.4GHZ","384 KB","3 MB","32 MB",95,"",0,""],
["AMD Ryzen 5 3600",6,12,"3.6GHZ","4.2GHZ","384 KB","3 MB","32 MB",65,"",0,""],
["AMD Ryzen 5 3580U Microsoft Surface® Edition",4,8,"2.1GHZ","3.7GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 9 Graphics",9,"1300MHZ"],
["AMD Ryzen 5 3550H",4,8,"2.1GHZ","3.7GHZ","384 KB","2 MB","4 MB",35,"Radeon Vega 8 Graphics",8,"1200MHZ"],
["AMD Ryzen 5 3500U",4,8,"2.1GHZ","3.7GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 8 Graphics",8,"1200MHZ"],
["AMD Ryzen 5 3500C",4,8,"2.1GHZ","3.7GHZ","384 KB","2 MB","4 MB",15,"AMD Radeon Graphics",8,"1200MHZ"],
["AMD Ryzen 5 3500 Processor",6,6,"3.6GHZ","4.1GHZ","384 KB","3 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 3450U",4,8,"2.1GHZ","3.5GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 8 Graphics",0,"1200MHZ"],
["AMD Ryzen 5 3400GE",4,8,"3.3GHZ","4GHZ","384 KB","2 MB","4 MB",35,"Radeon Vega 11 Graphics",11,"1300MHZ"],
["AMD Ryzen 5 3400G",4,8,"3.7GHZ","4.2GHZ","384 KB","2 MB","4 MB",65,"Radeon RX Vega 11 Graphics",11,"1400MHZ"],
["AMD Ryzen 3 3350U",4,4,"2.1GHZ","3.5GHZ","348 KB","2 MB","4 MB",15,"Radeon Vega 6 Graphics",6,"1200MHZ"],
["AMD Ryzen 3 3300X",4,8,"3.8GHZ","4.3GHZ","256 KB","2 MB","16 MB",65,"",0,""],
["AMD Ryzen 3 3300U",4,4,"2.1GHZ","3.5GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 6 Graphics",6,"1200MHZ"],
["AMD Ryzen 3 3250U",2,4,"2.6GHZ","3.5GHZ","192 KB","1 MB","4 MB",15,"AMD Radeon Graphics",3,"1200MHZ"],
["AMD Ryzen 3 3250C",2,4,"2.6GHZ","3.5GHZ","192 KB","1 MB","4 MB",15,"AMD Radeon Graphics",3,"1200MHZ"],
["AMD Ryzen 3 3200U",2,4,"2.6GHZ","3.5GHZ","192 KB","1 MB","4 MB",15,"Radeon Vega 3 Graphics",3,"1200MHZ"],
["AMD Ryzen 3 3200GE",4,4,"3.3GHZ","3.8GHZ","384 KB","2 MB","4 MB",35,"Radeon Vega 8 Graphics",8,"1200MHZ"],
["AMD Ryzen 3 3200G",4,4,"3.6GHZ","4GHZ","384 KB","2 MB","4 MB",65,"Radeon Vega 8 Graphics",8,"1250MHZ"],
["AMD Ryzen 3 3100",4,8,"3.6GHZ","3.9GHZ","256 KB","2 MB","16 MB",65,"",0,""],
["AMD Athlon Gold PRO 3150GE",4,4,"3.3GHZ","3.8GHZ","384 KB","2 MB","4 MB",35,"Radeon  Graphics",3,"1100MHZ"],
["AMD Athlon Gold PRO 3150G",4,4,"3.5GHZ","3.9GHZ","384 KB","2 MB","4 MB",65,"Radeon  Graphics",3,"1100MHZ"],
["AMD Athlon PRO 3145B",2,4,"2.4GHZ","3.3GHZ","192 KB","1 MB","4 MB",15,"AMD Radeon Graphics",3,"1000MHZ"],
["AMD Athlon Silver PRO 3125GE",2,4,"3.4GHZ","3.4GHZ","192 KB","1 MB","4 MB",35,"Radeon  Graphics",3,"1100MHZ"],
["AMD Athlon PRO 3045B",2,2,"2.3GHZ","3.2GHZ","192 KB","1 MB","4 MB",15,"AMD Radeon Graphics",2,"1100MHZ"],
["AMD Athlon Gold 3150U",2,4,"2.4GHZ","3.3GHZ","192 KB","1 MB","4 MB",15,"AMD Radeon Graphics",3,"1000MHZ"],
["AMD Athlon Gold 3150GE",4,4,"3.3GHZ","3.8GHZ","384 KB","2 MB","4 MB",35,"Radeon  Graphics",3,"1100MHZ"],
["AMD Athlon Gold 3150G",4,4,"3.5GHZ","3.9GHZ","384 KB","2 MB","4 MB",65,"Radeon  Graphics",3,"1100MHZ"],
["AMD Athlon Gold 3150C",2,4,"2.4GHZ","3.3GHZ","192 KB","1 MB","4 MB",15,"AMD Radeon Graphics",3,"1100MHZ"],
["AMD Athlon Silver 3050U",2,2,"2.3GHZ","3.2GHZ","192 KB","1 MB","4 MB",15,"AMD Radeon Graphics",2,"1100MHZ"],
["AMD Athlon Silver 3050GE",2,4,"3.4GHZ","3.4GHZ","192 KB","1 MB","4 MB",35,"Radeon  Graphics",3,"1100MHZ"],
["AMD Athlon Silver 3050e",2,4,"1.4GHZ","2.8GHZ","","1 MB","4 MB",6,"AMD Radeon Graphics",3,"1000MHZ"],
["AMD Athlon  Silver 3050C",2,2,"2.3GHZ","3.2GHZ","192 KB","1 MB","4 MB",15,"AMD Radeon Graphics",2,"1100MHZ"],
["AMD Athlon 3000G",2,4,"3.5GHZ","","192 KB","1 MB","4 MB",35,"Radeon Vega 3 Graphics",3,"1100MHZ"],
["AMD Athlon PRO 300U Mobile Processor",2,4,"2.4GHZ","3.3GHZ","384 KB","1 MB","4 MB",15,"Radeon Vega 3 Graphics",3,"1000MHZ"],
["AMD Athlon PRO 300GE",2,4,"3.4GHZ","","192 KB","1 MB","4 MB",35,"Radeon Vega 3 Graphics",3,"1100MHZ"],
["AMD Athlon 320GE",2,4,"3.5GHZ","","192 KB","1 MB","4 MB",35,"Radeon Vega 3 Graphics",3,"1100MHZ"],
["AMD Athlon 300U",2,4,"2.4GHZ","3.3GHZ","192 KB","1 MB","4 MB",15,"Radeon Vega 3 Graphics",3,"1000MHZ"],
["AMD Athlon 300GE",2,4,"3.4GHZ","","192 KB","1 MB","4 MB",35,"Radeon Vega 3 Graphics",3,"1100MHZ"],
["AMD Athlon PRO 200U Mobile Processor",2,4,"2.3GHZ","3.2GHZ","192 KB","1 MB","4 MB",15,"Radeon Vega 3 Graphics",3,"1000MHZ"],
["AMD Athlon PRO 200GE",2,4,"3.2GHZ","","192 KB","1 MB","4 MB",35,"Radeon Vega 3 Graphics",3,"1000MHZ"],
["AMD Athlon 240GE",2,4,"3.5GHZ","","192 KB","1 MB","4 MB",35,"Radeon Vega 3 Graphics",3,"1000MHZ"],
["AMD Athlon 220GE",2,4,"3.4GHZ","","192 KB","1 MB","4 MB",35,"Radeon Vega 3 Graphics",3,"1000MHZ"],
["AMD Athlon 200GE",2,4,"3.2GHZ","","192 KB","1 MB","4 MB",35,"Radeon Vega 3 Graphics",3,"1000MHZ"],
["AMD Ryzen Threadripper 2990WX",32,64,"3GHZ","4.2GHZ","3072 KB","16 MB","64 MB",250,"",0,""],
["AMD Ryzen Threadripper 2970WX",24,48,"3GHZ","4.2GHZ","2304 KB","12 MB","64 MB",250,"",0,""],
["AMD Ryzen Threadripper 2950X",16,32,"3.5GHZ","4.4GHZ","1536 KB","8 MB","32 MB",180,"",0,""],
["AMD Ryzen Threadripper 2920X",12,24,"3.5GHZ","4.3GHZ","1152 KB","6 MB","32 MB",180,"",0,""],
["AMD Ryzen 7 PRO 2700X",8,16,"3.6GHZ","4.1GHZ","768 KB","4 MB","16 MB",95,"",0,""],
["AMD Ryzen 7 PRO 2700U",4,8,"2.2GHZ","3.8GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 10 Graphics",10,"1300MHZ"],
["AMD Ryzen 7 PRO 2700",8,16,"3.2GHZ","4.1GHZ","768 KB","4 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 PRO 2600",6,12,"3.4GHZ","3.9GHZ","576 KB","3 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 PRO 2500U",4,8,"2GHZ","3.6GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 8 Graphics",8,"1100MHZ"],
["AMD Ryzen 5 PRO 2400GE",4,8,"3.2GHZ","3.8GHZ","384 KB","2 MB","4 MB",35,"Radeon Vega 11 Graphics",11,"1250MHZ"],
["AMD Ryzen 5 PRO 2400G",4,8,"3.6GHZ","3.9GHZ","384 KB","2 MB","4 MB",65,"Radeon Vega 11 Graphics",11,"1250MHZ"],
["AMD Ryzen 3 PRO 2300U",4,4,"2GHZ","3.4GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 6 Graphics",6,"1100MHZ"],
["AMD Ryzen 3 PRO 2200GE",4,4,"3.2GHZ","3.6GHZ","384 KB","2 MB","4 MB",35,"Radeon Vega 8 Graphics",8,"1100MHZ"],
["AMD Ryzen 3 PRO 2200G",4,4,"3.5GHZ","3.7GHZ","384 KB","2 MB","4 MB",65,"Radeon Vega 8 Graphics",8,"1100MHZ"],
["AMD Ryzen 7 2800H",4,8,"3.3GHZ","3.8GHZ","192 KB","2 MB","4 MB",45,"Radeon RX Vega 11 Graphics",11,"1300MHZ"],
["AMD Ryzen 7 2700X",8,16,"3.7GHZ","4.3GHZ","768 KB","4 MB","16 MB",105,"",0,""],
["AMD Ryzen 7 2700U",4,8,"2.2GHZ","3.8GHZ","384 KB","2 MB","4 MB",15,"Radeon RX Vega 10 Graphics",10,"1300MHZ"],
["AMD Ryzen 7 2700E Processor",8,16,"2.8GHZ","4GHZ","768 KB","4 MB","16 MB",45,"",0,""],
["AMD Ryzen 7 2700",8,16,"3.2GHZ","4.1GHZ","768 KB","4 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 2600X",6,12,"3.6GHZ","4.2GHZ","576 KB","3 MB","16 MB",95,"",0,""],
["AMD Ryzen 5 2600H",4,8,"3.2GHZ","3.6GHZ","192 KB","2 MB","4 MB",45,"Radeon Vega 8 Graphics",8,"1100MHZ"],
["AMD Ryzen 5 2600E",6,12,"3.1GHZ","4GHZ","578 KB","3 MB","16 MB",45,"",0,""],
["AMD Ryzen 5 2600",6,12,"3.4GHZ","3.9GHZ","576 KB","3 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 2500X",4,8,"3.6GHZ","4GHZ","384 KB","2 MB","8 MB",65,"",0,""],
["AMD Ryzen 5 2500U",4,8,"2GHZ","3.6GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 8 Graphics",8,"1100MHZ"],
["AMD Ryzen 5 2400GE",4,8,"3.2GHZ","3.8GHZ","384 KB","2 MB","4 MB",35,"Radeon RX Vega 11 Graphics",11,"1250MHZ"],
["AMD Ryzen 5 2400G",4,8,"3.6GHZ","3.9GHZ","384 KB","2 MB","4 MB",65,"Radeon RX Vega 11 Graphics",11,"1250MHZ"],
["AMD Ryzen 3 2300X",4,4,"3.5GHZ","4GHZ","384 KB","2 MB","8 MB",65,"",0,""],
["AMD Ryzen 3 2300U",4,4,"2GHZ","3.4GHZ","384 KB","2 MB","4 MB",15,"Radeon Vega 6 Graphics",6,"1100MHZ"],
["AMD Ryzen 3 2200U",2,4,"2.5GHZ","3.4GHZ","384 KB","1 MB","4 MB",15,"Radeon Vega 3 Graphics",3,"1100MHZ"],
["AMD Ryzen 3 2200GE",4,4,"3.2GHZ","3.6GHZ","384 KB","2 MB","4 MB",35,"Radeon Vega 8 Graphics",8,"1100MHZ"],
["AMD Ryzen 3 2200G",4,4,"3.5GHZ","3.7GHZ","384 KB","2 MB","4 MB",65,"Radeon Vega 8 Graphics",8,"1100MHZ"],
["AMD Ryzen Threadripper 1950X",16,32,"3.4GHZ","4GHZ","1536 KB","8 MB","32 MB",180,"",0,""],
["AMD Ryzen Threadripper 1920X",12,24,"3.5GHZ","4GHZ","1152 KB","6 MB","32 MB",180,"",0,""],
["AMD Ryzen Threadripper 1900X",8,16,"3.8GHZ","4GHZ","768 KB","4 MB","16 MB",180,"",0,""],
["AMD Ryzen 7 PRO 1700X Processor",8,16,"3.4GHZ","3.8GHZ","","4 MB","16 MB",95,"",0,""],
["AMD Ryzen 7 PRO 1700",8,16,"3GHZ","3.7GHZ","768 KB","4 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 PRO 1600",6,12,"3.2GHZ","3.6GHZ","576 KB","3 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 PRO 1500",4,8,"3.5GHZ","3.7GHZ","384 KB","2 MB","16 MB",65,"",0,""],
["AMD Ryzen 3 PRO 1300",4,4,"3.5GHZ","3.7GHZ","384 KB","2 MB","8 MB",65,"",0,""],
["AMD Ryzen 3 PRO 1200",4,4,"3.1GHZ","3.4GHZ","384 KB","2 MB","8 MB",65,"",0,""],
["AMD Ryzen 7 1800X",8,16,"3.6GHZ","4GHZ","768 KB","4 MB","16 MB",95,"",0,""],
["AMD Ryzen 7 1700X",8,16,"3.4GHZ","3.8GHZ","768 KB","4 MB","16 MB",95,"",0,""],
["AMD Ryzen 7 1700 Processor",8,16,"3GHZ","3.7GHZ","768 KB","4 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 1600X",6,12,"3.6GHZ","4GHZ","576 KB","3 MB","16 MB",95,"",0,""],
["AMD Ryzen 5 1600 (AF)",6,12,"3.2GHZ","3.6GHZ","576 KB","3 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 1600",6,12,"3.2GHZ","3.6GHZ","576 KB","3 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 1500X",4,8,"3.5GHZ","3.7GHZ","384 KB","2 MB","16 MB",65,"",0,""],
["AMD Ryzen 5 1400",4,8,"3.2GHZ","3.4GHZ","384 KB","2 MB","8 MB",65,"",0,""],
["AMD Ryzen 3 1300X",4,4,"3.5GHZ","3.7GHZ","384 KB","2 MB","8 MB",65,"",0,""],
["AMD Ryzen 3 1200",4,4,"3.1GHZ","3.4GHZ","384 KB","2 MB","8 MB",65,"",0,""],
["AMD 3020e",2,2,"1.2GHZ","2.6GHZ","","1 MB","4 MB",6,"AMD Radeon Graphics",3,"1000MHZ"],
["AMD 3015e",2,4,"1.2GHZ","2.3GHZ","","1 MB","4 MB",6,"AMD Radeon Graphics",3,"600MHZ"],
["AMD 3015Ce",2,4,"1.2GHZ","2.3GHZ","","1 MB","4 MB",6,"Radeon  Graphics",3,"600MHZ"],
["FX-9590",8,8,"4.7GHZ","5GHZ","384 KB","8 MB","8 MB",220,"",0,""],
["FX-9370",8,8,"4.4GHZ","4.7GHZ","384 KB","8 MB","8 MB",220,"",0,""],
["FX-8370E",8,8,"3.3GHZ","4.3GHZ","384 KB","8 MB","8 MB",95,"",0,""],
["FX-8370",8,8,"4GHZ","4.3GHZ","384 KB","8 MB","8 MB",125,"",0,""],
["FX-8370",8,8,"4GHZ","4.3GHZ","384 KB","8 MB","8 MB",125,"",0,""],
["FX-8350",8,8,"4GHZ","4.2GHZ","384 KB","8 MB","8 MB",125,"",0,""],
["FX-8350",8,8,"4GHZ","4.2GHZ","384 KB","8 MB","8 MB",125,"",0,""],
["FX-8320E",8,8,"3.2GHZ","4GHZ","384 KB","8 MB","8 MB",95,"",0,""],
["FX-8320",8,8,"3.5GHZ","4GHZ","384 KB","8 MB","8 MB",125,"",0,""],
["FX-8310",8,8,"3.4GHZ","4.3GHZ","","8 MB","",95,"",0,""],
["FX-8300",8,8,"3.3GHZ","4.2GHZ","384 KB","8 MB","8 MB",95,"",0,""],
["FX-8150",8,8,"3.6GHZ","4.2GHZ","384 KB","8 MB","8 MB",125,"",0,""],
["FX-8120",8,8,"3.1GHZ","4GHZ","384 KB","8 MB","8 MB",125,"",0,""],
["FX-6350",6,6,"3.9GHZ","4.2GHZ","288 KB","6 MB","8 MB",125,"",0,""],
["FX-6350",6,6,"3.9GHZ","4.2GHZ","288 KB","6 MB","8 MB",125,"",0,""],
["FX-6300",6,6,"3.5GHZ","3.8GHZ","288 KB","6 MB","8 MB",95,"",0,""],
["FX-6200",6,6,"3.8GHZ","4.1GHZ","288 KB","6 MB","8 MB",125,"",0,""],
["FX 6100",6,6,"3.3GHZ","3.9GHZ","288 KB","6 MB","8 MB",95,"",0,""],
["FX-4350",4,4,"4.2GHZ","4.3GHZ","192 KB","4 MB","8 MB",125,"",0,""],
["FX-4320",4,4,"4GHZ","4.1GHZ","192 KB","4 MB","4 MB",95,"",0,""],
["FX-4300",4,4,"3.8GHZ","4GHZ","192 KB","4 MB","4 MB",95,"",0,""],
["FX-4170",4,4,"4.2GHZ","4.3GHZ","192 KB","4 MB","8 MB",125,"",0,""],
["FX-4130",4,4,"3.8GHZ","3.9GHZ","192 KB","4 MB","4 MB",125,"",0,""],
["FX-4100",4,4,"3.6GHZ","3.8GHZ","192 KB","4 MB","8 MB",95,"",0,""],
["7th Gen FX 9830P APU",4,4,"3GHZ","3.7GHZ","","2 MB","",35,"AMD Radeon R7 Graphics",8,"900MHZ"],
["7th Gen FX 9800P APU",4,4,"2.7GHZ","3.6GHZ","","2 MB","",15,"AMD Radeon R7 Graphics",8,"758MHZ"],
["6th Gen FX-8800P APU",4,4,"2.1GHZ","3.4GHZ","","2 MB","",15,"AMD Radeon R7 Graphics",8,"800MHZ"],
["FX-7600P",4,4,"2.7GHZ","3.6GHZ","","4 MB","",35,"AMD Radeon R7 Graphics",8,"686MHZ"],
["FX-7500",4,4,"2.1GHZ","3.3GHZ","","4 MB","",20,"AMD Radeon R7 Graphics",6,"553MHZ"],
["FX-8800P",4,4,"2.1GHZ","3.4GHZ","","2 MB","",0,"AMD Radeon R7 Graphics",8,"800MHZ"],
["7th Gen A12-9800E APU",4,4,"3.1GHZ","3.8GHZ","","2 MB","",35,"Radeon R7 Series",8,"900MHZ"],
["7th Gen A12-9800 APU",4,4,"3.8GHZ","4.2GHZ","","2 MB","",65,"Radeon R7 Series",8,"1108MHZ"],
["7th Gen A12-9730P APU",4,4,"2.8GHZ","3.5GHZ","","2 MB","",35,"AMD Radeon R7 Graphics",6,"900MHZ"],
["7th Gen A12-9700P APU",4,4,"2.5GHZ","3.4GHZ","","2 MB","",15,"AMD Radeon R7 Graphics",6,"758MHZ"],
["7th Gen AMD PRO A12-9800E APU",4,4,"3.1GHZ","3.8GHZ","","2 MB","",35,"R7",8,"900MHZ"],
["7th Gen AMD PRO A12-9800 APU",4,4,"3.8GHZ","4.2GHZ","","2 MB","",65,"R7",8,"1108MHZ"],
["6th Gen AMD PRO A12-8870E APU",4,4,"2.9GHZ","3.8GHZ","","2 MB","",35,"R7",8,"900MHZ"],
["6th Gen AMD PRO A12-8870 APU",4,4,"3.7GHZ","4.2GHZ","","2 MB","",65,"R7",8,"1108MHZ"],
["7th Gen AMD PRO A12-9830B APU",4,4,"3GHZ","3.7GHZ","","2 MB","",35,"R7",8,"900MHZ"],
["7th Gen AMD PRO A12-9800B APU",4,4,"2.7GHZ","3.6GHZ","","2 MB","",15,"R7",8,"758MHZ"],
["6th Gen AMD PRO A12-8830B APU",4,4,"2.5GHZ","3.4GHZ","","2 MB","",0,"R7",6,"758MHZ"],
["6th Gen AMD PRO A12-8800B APU",4,4,"2.1GHZ","3.4GHZ","","2 MB","",15,"AMD Radeon R7 Graphics",8,"800MHZ"],
["7th Gen A10-9700E APU",4,4,"3GHZ","3.5GHZ","","2 MB","",35,"Radeon R7 Series",6,"847MHZ"],
["7th Gen A10-9700 APU",4,4,"3.5GHZ","3.8GHZ","","2 MB","",65,"Radeon R7 Series",6,"1029MHZ"],
["A10-7890K",4,4,"4.1GHZ","4.3GHZ","256 KB","4 MB","",95,"AMD Radeon R7 Graphics",8,"866MHZ"],
["A10-7870K",4,4,"3.9GHZ","4.1GHZ","256 KB","4 MB","",95,"AMD Radeon R7 Graphics",8,"866MHZ"],
["A10-7870K",4,4,"3.9GHZ","4.1GHZ","256 KB","4 MB","",95,"AMD Radeon R7 Graphics",8,"866MHZ"],
["A10-7860K",4,4,"3.6GHZ","4GHZ","256 KB","4 MB","",65,"AMD Radeon R7 Graphics",8,"757MHZ"],
["A10-7860K",4,4,"3.6GHZ","4GHZ","256 KB","4 MB","",65,"AMD Radeon R7 Graphics",8,"757MHZ"],
["A10-7850K",4,4,"3.7GHZ","4GHZ","256 KB","4 MB","",95,"AMD Radeon R7 Graphics",8,"720MHZ"],
["A10-7800",4,4,"3.5GHZ","3.9GHZ","256 KB","4 MB","",0,"AMD Radeon R7 Graphics",8,"720MHZ"],
["A10-7700K",4,4,"3.4GHZ","3.8GHZ","256 KB","4 MB","",0,"AMD Radeon R7 Graphics",6,"720MHZ"],
["A10-6800K",4,4,"4.1GHZ","4.4GHZ","192 KB","4 MB","",100,"AMD Radeon HD 8670D",0,"844MHZ"],
["A10-6790K",4,4,"4GHZ","4.3GHZ","192 KB","4 MB","",100,"AMD Radeon HD 8670D",0,"844MHZ"],
["A10-6700T",4,4,"2.5GHZ","3.5GHZ","192 KB","4 MB","",45,"AMD Radeon HD 8650D",0,"720MHZ"],
["A10-6700",4,4,"3.7GHZ","4.3GHZ","192 KB","4 MB","",65,"AMD Radeon HD 8670D",0,"844MHZ"],
["7th Gen A10-9630P APU",4,4,"2.6GHZ","3.3GHZ","","2 MB","",35,"AMD Radeon R5 Graphics",6,"800MHZ"],
["7th Gen A10-9600P APU",4,4,"2.4GHZ","3.3GHZ","","2 MB","",15,"AMD Radeon R5 Graphics",6,"720MHZ"],
["6th Gen A10-8700P APU",4,4,"1.8GHZ","3.2GHZ","","2 MB","",15,"AMD Radeon R6 Graphics",6,"800MHZ"],
["A10-7400P",4,4,"2.5GHZ","3.4GHZ","","4 MB","",35,"AMD Radeon R6 Graphics",6,"654MHZ"],
["A10-7300",4,4,"1.9GHZ","3.2GHZ","","4 MB","",20,"AMD Radeon R6 Graphics",6,"553MHZ"],
["A10 Micro-6700T",4,4,"2.2GHZ","","","2 MB","",4.5,"AMD Radeon R6 Graphics",0,""],
["A10-8700P",4,4,"1.8GHZ","3.2GHZ","","2 MB","",0,"AMD Radeon R6 Graphics",6,"800MHZ"],
["7th Gen AMD PRO A10-9700E APU",4,4,"3GHZ","3.5GHZ","","2 MB","",35,"R7",6,"847MHZ"],
["7th Gen AMD PRO A10-9700 APU",4,4,"3.5GHZ","3.8GHZ","","2 MB","",65,"R7",6,"1029MHZ"],
["6th Gen AMD PRO A10-8850B APU",4,4,"3.9GHZ","4.1GHZ","","4 MB","",95,"AMD Radeon R7 Graphics",8,"800MHZ"],
["6th Gen AMD PRO A10-8770E APU",4,4,"2.8GHZ","3.5GHZ","","2 MB","",35,"R7",6,"847MHZ"],
["6th Gen AMD PRO A10-8770 APU",4,4,"3.5GHZ","3.8GHZ","","2 MB","",65,"R7",6,"1029MHZ"],
["6th Gen AMD PRO A10-8750B APU",4,4,"3.6GHZ","4GHZ","","4 MB","",65,"AMD Radeon R7 Graphics",8,"757MHZ"],
["A10 PRO-7850B",4,4,"3.7GHZ","4GHZ","256 KB","4 MB","",95,"AMD Radeon R7 Graphics",8,"720MHZ"],
["A10 PRO-7800B",4,4,"3.5GHZ","3.9GHZ","256 KB","4 MB","",65,"AMD Radeon R7 Graphics",8,"720MHZ"],
["7th Gen AMD PRO A10-9730B APU",4,4,"2.8GHZ","3.5GHZ","","2 MB","",35,"R7",6,"900MHZ"],
["7th Gen AMD PRO A10-9700B APU",4,4,"2.5GHZ","3.4GHZ","","2 MB","",15,"R7",6,"758MHZ"],
["6th Gen AMD PRO A10-8730B APU",4,4,"2.4GHZ","3.3GHZ","","2 MB","",0,"R5",6,"720MHZ"],
["6th Gen AMD PRO A10-8700B APU",4,4,"1.8GHZ","3.2GHZ","","2 MB","",15,"AMD Radeon R6 Graphics",6,"800MHZ"],
["A10 PRO-7350B",4,4,"2.1GHZ","3.3GHZ","","4 MB","",19,"AMD Radeon R6 Graphics",6,"553MHZ"],
["A10-6800B",4,4,"4.1GHZ","4.4GHZ","192 KB","4 MB","",45,"AMD Radeon HD 8670D",0,"844MHZ"],
["A10-6790B",4,4,"4GHZ","4.3GHZ","192 KB","4 MB","",45,"AMD Radeon HD 8670D",0,"844MHZ"],
["7th Gen A9-9425 APU",2,2,"3.1GHZ","3.7GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",3,"900MHZ"],
["7th Gen A9-9420 APU",2,2,"3GHZ","3.6GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",3,"847MHZ"],
["7th Gen A9-9410 APU",2,2,"2.9GHZ","3.5GHZ","","1 MB","",10-25/25,"AMD Radeon R5 Graphics",3,"800MHZ"],
["7th Gen A8-9600 APU",4,4,"3.1GHZ","3.4GHZ","","2 MB","",65,"Radeon R7 Series",6,"900MHZ"],
["A8-7670K",4,4,"3.6GHZ","3.9GHZ","256 KB","4 MB","",95,"AMD Radeon R7 Graphics",6,"757MHZ"],
["A8-7650K",4,4,"3.3GHZ","3.8GHZ","256 KB","4 MB","",95,"AMD Radeon R7 Graphics",6,"720MHZ"],
["A8-7650K",4,4,"3.3GHZ","3.8GHZ","256 KB","4 MB","",95,"AMD Radeon R7 Graphics",6,"720MHZ"],
["A8-7600",4,4,"3.1GHZ","3.8GHZ","256 KB","4 MB","",65,"AMD Radeon R7 Graphics",6,"720MHZ"],
["A8-6600K",4,4,"3.9GHZ","4.2GHZ","192 KB","4 MB","",65,"AMD Radeon HD 8570D",0,"844MHZ"],
["A8-6500T",4,4,"2.1GHZ","3.1GHZ","192 KB","4 MB","",45,"AMD Radeon HD 8550D",0,"720MHZ"],
["A8-6500",4,4,"3.5GHZ","4.1GHZ","192 KB","4 MB","",65,"AMD Radeon HD 8570D",0,"800MHZ"],
["6th Gen A8-8600P APU",4,4,"1.6GHZ","3GHZ","","2 MB","",15,"AMD Radeon R6 Graphics",6,"720MHZ"],
["A8-7410",4,4,"2.2GHZ","2.5GHZ","","2 MB","",15,"AMD Radeon R5 Graphics",0,"847MHZ"],
["A8-7200P",4,4,"2.4GHZ","3.3GHZ","","4 MB","",100,"AMD Radeon R5 Graphics",4,"626MHZ"],
["A8-7100",4,4,"1.8GHZ","3GHZ","","4 MB","",20,"AMD Radeon R5 Graphics",4,"514MHZ"],
["A8-8600P",4,4,"1.6GHZ","3GHZ","","2 MB","",0,"AMD Radeon R6 Graphics",6,"720MHZ"],
["A8-6410",4,4,"2GHZ","2.4GHZ","","2 MB","",15,"AMD Radeon R5 Graphics",0,"847MHZ"],
["7th Gen AMD PRO A8-9600 APU",4,4,"3.1GHZ","3.4GHZ","","2 MB","",65,"R7",6,"900MHZ"],
["6th Gen AMD PRO A8-8650B APU",4,4,"3.2GHZ","3.9GHZ","","4 MB","",65,"AMD Radeon R7 Graphics",6,"757MHZ"],
["A8 PRO-7600B",4,4,"3.1GHZ","3.8GHZ","","4 MB","",65,"AMD Radeon R7 Graphics",6,"720MHZ"],
["7th Gen AMD PRO A8-9630B",4,4,"2.6GHZ","3.3GHZ","","2 MB","",35,"R5",6,"800MHZ"],
["7th Gen AMD PRO A8-9600B APU",4,4,"2.4GHZ","3.3GHZ","","2 MB","",15,"R5",6,"720MHZ"],
["6th Gen AMD PRO A8-8600B APU",4,4,"1.6GHZ","3GHZ","","2 MB","",15,"AMD Radeon R6 Graphics",6,"720MHZ"],
["A8 PRO-7150B",4,4,"1.9GHZ","3.2GHZ","","4 MB","",100,"AMD Radeon R5 Graphics",6,"533MHZ"],
["A8-6500B",4,4,"3.5GHZ","4.1GHZ","192 KB","4 MB","",65,"AMD Radeon HD 8570D",0,"800MHZ"],
["7th Gen A6-9550 APU",2,2,"3.8GHZ","4GHZ","","1 MB","",65,"Radeon R5 Series",6,"1029MHZ"],
["7th Gen A6-9500E APU",2,2,"3GHZ","3.4GHZ","","1 MB","",35,"Radeon R5 Series",4,"800MHZ"],
["7th Gen A6-9500 APU",2,2,"3.5GHZ","3.8GHZ","","1 MB","",65,"Radeon R5 Series",6,"1029MHZ"],
["A6-7470K",2,2,"3.7GHZ","4GHZ","256 KB","1 MB","",65,"AMD Radeon R5 Graphics",4,"800MHZ"],
["A6-7400K",2,2,"3.5GHZ","3.9GHZ","128 KB","1 MB","",65,"AMD Radeon R5 Graphics",4,"758MHZ"],
["A6-6420K",2,2,"4GHZ","4.2GHZ","96 KB","1 MB","",65,"AMD Radeon HD 8470D",0,"800MHZ"],
["A6-6400K",2,2,"3.9GHZ","4.1GHZ","96 KB","1 MB","",65,"AMD Radeon HD 8470D",0,"800MHZ"],
["A6-6310",4,4,"2.4GHZ","2.4GHZ","128 KB","2 MB","",15,"AMD Radeon R4 Graphics",0,"800MHZ"],
["A6-5200",4,4,"2GHZ","","256 KB","2 MB","",25,"AMD Radeon HD 8400",0,"600MHZ"],
["7th Gen A6-9225 APU",2,2,"2.6GHZ","3.1GHZ","","1 MB","",15,"AMD Radeon R4 Graphics",3,"686MHZ"],
["7th Gen A6-9220C APU",2,2,"1.8GHZ","2.7GHZ","160 KB","1 MB","",6,"Radeon R5 Graphics",3,"720MHZ"],
["7th Gen A6-9220 APU",2,2,"2.5GHZ","2.9GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",3,"655MHZ"],
["7th Gen A6-9210 APU",2,2,"2.4GHZ","2.8GHZ","","1 MB","",15,"AMD Radeon R4 Graphics",3,"600MHZ"],
["A6-7000",2,2,"2.2GHZ","3GHZ","","1 MB","",17,"AMD Radeon R4 Graphics",3,"533MHZ"],
["A6-5350M",2,2,"2.9GHZ","3.5GHZ","","2 MB","",35,"AMD Radeon HD 8450G",0,"533MHZ"],
["A6-5200M",4,4,"2GHZ","","","2 MB","",25,"AMD Radeon HD 8400",0,""],
["A6-8500P",2,2,"1.6GHZ","3GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",4,"800MHZ"],
["A6-7310",4,4,"2GHZ","2.4GHZ","","2 MB","",15,"AMD Radeon R4 Graphics",0,"800MHZ"],
["7th Gen AMD PRO A6-9500E APU",2,2,"3GHZ","3.4GHZ","","1 MB","",35,"R5",4,"800MHZ"],
["7th Gen AMD PRO A6-9500 APU",2,2,"3.5GHZ","3.8GHZ","","1 MB","",65,"R5",6,"1029MHZ"],
["6th Gen AMD PRO A6-8570E APU",2,2,"3GHZ","3.4GHZ","","1 MB","",35,"R5",4,"800MHZ"],
["6th Gen AMD PRO A6-8570 APU",2,2,"3.5GHZ","3.8GHZ","","1 MB","",65,"R5",6,"1029MHZ"],
["6th Gen AMD PRO A6-8550B APU",2,2,"3.7GHZ","4GHZ","","1 MB","",65,"AMD Radeon R5 Graphics",4,"800MHZ"],
["A6 PRO-7400B",2,2,"3.5GHZ","3.9GHZ","","1 MB","",65,"AMD Radeon R5 Graphics",4,"756MHZ"],
["7th Gen AMD PRO A6-9500B APU",2,2,"2.3GHZ","3.2GHZ","","1 MB","",15,"R5",4,"800MHZ"],
["7th Gen AMD PRO A6-8350B APU",2,2,"3.1GHZ","3.7GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",3,""],
["7th Gen AMD PRO A6-7350B APU",2,2,"3GHZ","3.6GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",3,""],
["6th Gen AMD PRO A6-8530B APU",2,2,"2.3GHZ","3.2GHZ","","1 MB","",0,"R5",4,"800MHZ"],
["6th Gen AMD PRO A6-8500B APU",2,4,"1.6GHZ","3GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",4,"800MHZ"],
["A6 PRO-7050B",2,2,"2.2GHZ","3GHZ","","1 MB","",100,"AMD Radeon R4 Graphics",3,"533MHZ"],
["A6-6420B",2,2,"4GHZ","4.2GHZ","96 KB","1 MB","",65,"AMD Radeon HD 8470D",0,"800MHZ"],
["A6-6400B",2,2,"3.9GHZ","4.1GHZ","96 KB","1 MB","",65,"AMD Radeon HD 8470D",0,"800MHZ"],
["A4-7300",2,2,"3.8GHZ","4GHZ","96 KB","1 MB","",65,"AMD Radeon HD 8470D",0,"800MHZ"],
["A4-6320",2,2,"3.8GHZ","4GHZ","96 KB","1 MB","",65,"AMD Radeon HD 8370D",0,"760MHZ"],
["A4-6300",2,2,"3.7GHZ","3.9GHZ","96 KB","1 MB","",65,"AMD Radeon HD 8370D",0,"760MHZ"],
["7th Gen A4-9125 APU",2,2,"2.3GHZ","2.6GHZ","","1 MB","",15,"AMD Radeon R3 Graphics",2,"686MHZ"],
["7th Gen A4-9120C APU",2,2,"1.6GHZ","2.4GHZ","160 KB","1 MB","",6,"Radeon R4 Graphics",3,"600MHZ"],
["7th Gen A4-9120 APU",2,2,"2.2GHZ","2.5GHZ","","1 MB","",15,"AMD Radeon R3 Graphics",2,"655MHZ"],
["A4-7210",4,4,"1.8GHZ","2.2GHZ","","2 MB","",65,"AMD Radeon R3 Graphics",0,"686MHZ"],
["A4 Micro-6400T",4,4,"1.6GHZ","","","2 MB","",4.5,"AMD Radeon R3 Graphics",0,""],
["A4-6210",4,4,"1.8GHZ","","128 KB","2 MB","",15,"AMD Radeon R3 Graphics",0,"600MHZ"],
["A4-5100",4,4,"1.55GHZ","","256 KB","2 MB","",15,"AMD Radeon HD 8330",0,"500MHZ"],
["A4-5000",4,4,"1.5GHZ","","256 KB","2 MB","",15,"AMD Radeon HD 8330",0,"500MHZ"],
["6th Gen AMD PRO A4-8350B APU",2,2,"3.5GHZ","3.9GHZ","","1 MB","",65,"AMD Radeon R5 Graphics",4,"757MHZ"],
["A4 PRO-7350B",2,2,"3.4GHZ","3.8GHZ","","1 MB","",65,"AMD Radeon R5 Graphics",3,"514MHZ"],
["A4 PRO-7300B",2,2,"3.8GHZ","4GHZ","96 KB","1 MB","",65,"AMD Radeon HD 8470D",0,"800MHZ"],
["7th Gen AMD PRO A4-5350B APU",2,2,"3GHZ","3.6GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",3,""],
["7th Gen AMD PRO A4-4350B APU",2,2,"2.5GHZ","2.9GHZ","","1 MB","",15,"AMD Radeon R4 Graphics",3,""],
["A4 PRO-3350B",4,4,"2GHZ","2.4GHZ","","2 MB","",15,"AMD Radeon R4 Graphics",2,"800MHZ"],
["A4 PRO-3340B",4,4,"2.2GHZ","","","2 MB","",25,"AMD Radeon HD 8240 Graphics",2,"400MHZ"],
["Athlon 5370 APU",4,4,"2.2GHZ","","256 KB","2 MB","",25,"AMD Radeon R3 Graphics",0,"600MHZ"],
["Athlon 5350 APU",4,4,"2.05GHZ","","256 KB","2 MB","",25,"AMD Radeon R3 Graphics",0,"600MHZ"],
["Athlon 5150 APU",4,4,"1.6GHZ","","256 KB","2 MB","",25,"AMD Radeon R3 Graphics",0,"600MHZ"],
["Sempron 3850 APU",4,4,"1.3GHZ","","256 KB","2 MB","",25,"AMD Radeon R3 Graphics",0,"450MHZ"],
["Sempron 2650 APU",2,2,"1.45GHZ","","128 KB","1 MB","",25,"AMD Radeon R3 Graphics",0,"400MHZ"],
["7th Gen E2-9010 APU",2,2,"2GHZ","2.2GHZ","","1 MB","",15,"AMD Radeon R5 Graphics",2,"600MHZ"],
["E2-6110",4,4,"1.5GHZ","","","2 MB","",15,"AMD Radeon R2 Graphics",0,""],
["E2-3800",4,4,"1.3GHZ","","128 KB","2 MB","",15,"AMD Radeon HD 8280",0,"450MHZ"],
["E2-3000",2,2,"1.65GHZ","","","1 MB","",15,"AMD Radeon HD 8280",0,""],
["E2-7110",4,4,"1.8GHZ","1.8GHZ","","2 MB","",65,"AMD Radeon R2 Graphics",0,"600MHZ"],
["E1-7010",2,2,"1.5GHZ","1.5GHZ","","1 MB","",10,"AMD Radeon R2 Graphics",0,"400MHZ"],
["E1 Micro-6200T",2,2,"1.4GHZ","","","1 MB","",3.95,"AMD Radeon R2 Graphics",0,""],
["E1-6010",2,2,"1.35GHZ","","","1 MB","",10,"AMD Radeon R2 Graphics",0,""],
["E1-2500",2,2,"1.4GHZ","","","1 MB","",15,"AMD Radeon HD 8240",0,""],
["E1-2200",2,2,"1GHZ","","","1 MB","",9,"AMD Radeon HD 8210",0,""],
["E1-2100",2,2,"1GHZ","","","1 MB","",9,"AMD Radeon HD 8210",0,""],
["7th Gen AMD Athlon X4 970",4,4,"3.8GHZ","4GHZ","","2 MB","",65,"",0,""],
["7th Gen AMD Athlon X4 950",4,4,"3.5GHZ","3.8GHZ","","2 MB","",0,"",0,""],
["7th Gen AMD Athlon X4 940",4,4,"3.2GHZ","3.6GHZ","","2 MB","",0,"",0,""],
["880K",4,4,"4GHZ","4.2GHZ","256 KB","4 MB","",95,"",0,""],
["870K",4,4,"3.9GHZ","4.1GHZ","128 KB","4 MB","",95,"",0,""],
["860K",4,4,"3.7GHZ","4GHZ","128 KB","4 MB","",95,"",0,""],
["AMD Athlon 860K",4,4,"3.7GHZ","4GHZ","128 KB","4 MB","",95,"",0,""],
["845",4,4,"3.5GHZ","3.8GHZ","","2 MB","",0,"",0,""],
["AMD Athlon 760K",4,4,"3.8GHZ","4.1GHZ","","4 MB","",100,"",0,""],
["AMD Athlon 750K",4,4,"3.4GHZ","4GHZ","","4 MB","",100,"",0,""],
["AMD Athlon 750",4,4,"3.4GHZ","4GHZ","192 KB","4 MB","",65,"",0,""],
["AMD Athlon 740",4,4,"3.2GHZ","3.7GHZ","","4 MB","",65,"",0,""],
["AMD Athlon 641",4,4,"2.8GHZ","","512 KB","4 MB","",100,"",0,""],
["AMD Athlon 638",4,4,"2.7GHZ","","512 KB","4 MB","",65,"",0,""],
["AMD Athlon 631 (65W)",4,4,"2.6GHZ","","","4 MB","",65,"",0,""],
["AMD Athlon 631",4,4,"2.6GHZ","","","4 MB","",100,"",0,""],
["AMD Athlon 620e",4,4,"2.7GHZ","","","","",45,"",0,""],
["AMD Athlon 460",3,3,"3.4GHZ","","384 KB","1.5 MB","",95,"",0,""],
["AMD Athlon 425e",3,3,"2.7GHZ","","384 KB","1.5 MB","",45,"",0,""],
["AMD Athlon 255e",2,2,"3.1GHZ","","256 KB","2 MB","",45,"",0,""],
["AMD Phenom II 1075T",6,6,"3.5GHZ","","768 KB","3 MB","6 MB",95,"",0,""],
["AMD Phenom II 1045T",0,0,"2.7GHZ","3.2GHZ","768 KB","3 MB","6 MB",95,"",0,""],
["AMD Phenom II 980",4,4,"3.7GHZ","","512 KB","2 MB","6 MB",125,"",0,""],
["AMD Phenom II 975",4,4,"3.6GHZ","","512 KB","2 MB","6 MB",125,"",0,""],
["AMD Phenom II 965",4,4,"3.4GHZ","","","2 MB","",80,"",0,""],
["AMD Phenom II 960T",4,4,"3GHZ","3.4GHZ","512 KB","512 KB","",95,"",0,""],
["AMD Phenom II 850",4,4,"3.3GHZ","","512 KB","2 MB","",95,"",0,""],
["AMD Phenom II 840",4,4,"3.2GHZ","","512 KB","2 MB","",95,"",0,""],
["AMD Phenom II 570",2,2,"4GHZ","","","","6 MB",80,"",0,""],
["AMD Phenom II 555",2,2,"3.2GHZ","","","1 MB","",80,"",0,""],
["AMD Phenom II 565",2,2,"3.4GHZ","","256 KB","1 MB","6 MB",80,"",0,""],
["X940",4,4,"2.4GHZ","","512 KB","2 MB","",45,"",0,""],
["N970",4,4,"2.2GHZ","","512 KB","2 MB","",35,"",0,""],
["N960",4,4,"1.8GHZ","","512 KB","2 MB","",35,"",0,""],
["N870",3,3,"2.3GHZ","","384 KB","1.5 MB","",35,"",0,""],
["P860",3,3,"2GHZ","","384 KB","1.5 MB","",35,"",0,""],
["N660",2,2,"3GHZ","","256 KB","2 MB","",35,"",0,""],
["P650",2,2,"2.6GHZ","","256 KB","2 MB","",35,"",0,""],
["N640",2,2,"2.8GHZ","","256 KB","2 MB","",35,"",0,""],
["B99",4,4,"3.3GHZ","","","2 MB","",95,"",0,""],
["B97",4,4,"3.2GHZ","","","2 MB","",95,"",0,""],
["B95",0,0,"3GHZ","","","2 MB","",95,"",0,""],
["B77",3,3,"3.2GHZ","","","1.5 MB","",95,"",0,""],
["B75",3,3,"3GHZ","","","1.5 MB","",95,"",0,""],
["B60",2,2,"3.5GHZ","","","1 MB","",80,"",0,""],
["B59",2,2,"3.4GHZ","","","1 MB","",80,"",0,""],
["B57",2,2,"3.2GHZ","","","1 MB","",80,"",0,""],
];

String stringFromFreq(double freq) {
    final str = freq.toString();
    final idx = str.indexOf("00");
    return str.substring(0, idx == -1 ? str.length : idx);
}

class CPUInfo {
    // static info
    String name;
    int coreCount;
    int threadCount;
    String baseClock;
    String boostClock;
    String l1Cache;
    String l2Cache;
    String l3Cache;
    bool virtualization;
    String tdp;
    String iGPUName;
    int iGPUCoreCount;
    String iGPUClock;

    // dynamic info
    double clockSpeed = 0;
    double utilization = 0;
    double uptime = 0;
    int runningProcessCount = 0;
    int runningThreadCount = 0;
    int handlesCount = 0;

    int _prevTotal = 0;
    int _prevIdle = 0;

    CPUInfo({
        required this.name,
        required this.coreCount,
        required this.threadCount,
        required this.baseClock,
        required this.boostClock,
        required this.l1Cache,
        required this.l2Cache,
        required this.l3Cache,
        required this.virtualization,
        required this.tdp,
        required this.iGPUName,
        required this.iGPUCoreCount,
        required this.iGPUClock,
    });

    static CPUInfo fromRow(List<dynamic> row) {
        return CPUInfo(
            name: row[0],
            coreCount: row[1],
            threadCount: row[2],
            baseClock: row[3].replaceFirst("GHZ", " GHz").replaceFirst("MHZ", " MHz"),
            boostClock: row[4].replaceFirst("GHZ", " GHz").replaceFirst("MHZ", " MHz"),
            l1Cache: row[5],
            l2Cache: row[6],
            l3Cache: row[7],
            virtualization: false,
            tdp: row[8].toString() + " W",
            iGPUName: row[9],
            iGPUCoreCount: row[10],
            iGPUClock: row[11].replaceFirst("GHZ", " GHz").replaceFirst("MHZ", " MHz")
        );
    }

    static Future<CPUInfo> thisDeviceInfo() async {
        Map<String, String> lscpuInfo = {};
        Process.runSync("lscpu", []).stdout.split("\n").forEach((String row) {
            row = row.trimLeft();
            final colonIdx = row.indexOf(":");
            if (colonIdx != -1) {
                final propName = row.substring(0, colonIdx).trimRight();
                final data = row.substring(colonIdx + 1).trim();
                lscpuInfo[propName.toLowerCase()] = data;
            }
        });

        final name = lscpuInfo["model name"] ?? "Unknown CPU";
        var idx = name.indexOf("with");
        if (idx == -1) idx = name.indexOf("w/");
        final lookupName = name.substring(0, idx == -1 ? name.length : idx).replaceFirst("(OEM Only)", "").trim().toLowerCase();
        CPUInfo lookupInfo = CPUInfo(
            name: "",
            coreCount: 0,
            threadCount: 0,
            baseClock: "",
            boostClock: "",
            l1Cache: "",
            l2Cache: "",
            l3Cache: "",
            virtualization: false,
            tdp: "",
            iGPUName: "",
            iGPUCoreCount: 0,
            iGPUClock: ""
        );
        for (final row in cpuDatas) {
            String cpuName = row[0] as String;
            if (cpuName.toLowerCase().contains(lookupName)) {
                lookupInfo = CPUInfo.fromRow(row);
            }
        }
        
        // CPU name
        lookupInfo.name = name;
        
        // core count
        if (lscpuInfo["core(s) per socket"] != null) {
            lookupInfo.coreCount = int.parse(lscpuInfo["core(s) per socket"]!);
        }

        // thread count
        if (lscpuInfo["cpu(s)"] != null) {
            lookupInfo.threadCount = int.parse(lscpuInfo["cpu(s)"]!);
        }
        
        // no reliable way to get base clock
        // so simple use base clock from the lookup table

        // boost clock
        if (lscpuInfo["cpu max MHz"] != null) {
            var boostClock = double.parse(lscpuInfo["cpu max MHz"]!);
            if (boostClock >= 1000) {
                lookupInfo.boostClock = stringFromFreq(boostClock / 1000) + " Ghz";
            } else {
                lookupInfo.boostClock = stringFromFreq(boostClock) + " Mhz";
            }
        }

        // L3 cache
        if (lscpuInfo["l3 cache"] != null) {
            final data = lscpuInfo["l3 cache"]!;
            lookupInfo.l3Cache = data.substring(0, data.indexOf("(")).trim().replaceFirst("MiB", "MB").replaceFirst("KiB", "KB");
            if (data.contains("${lookupInfo.coreCount} instance")) {
                lookupInfo.l3Cache += " (per core)";
            } else if (data.contains("${lookupInfo.threadCount} instance")) {
                lookupInfo.l3Cache += " (per thread)";
            } else if (data.contains("1 instance")) {
                lookupInfo.l3Cache += " (shared)";
            }
        }
        
        // L2 cache
        if (lscpuInfo["l2 cache"] != null) {
            final data = lscpuInfo["l2 cache"]!;
            lookupInfo.l2Cache = data.substring(0, data.indexOf("(")).trim().replaceFirst("MiB", "MB").replaceFirst("KiB", "KB");
            if (data.contains("${lookupInfo.coreCount} instance")) {
                lookupInfo.l2Cache += " (per core)";
            } else if (data.contains("${lookupInfo.threadCount} instance")) {
                lookupInfo.l2Cache += " (per thread)";
            } else if (data.contains("1 instance")) {
                lookupInfo.l2Cache += " (shared)";
            }
        }
        
        // L1 Cache
        if (lscpuInfo["l1d cache"] != null) {
            final data = lscpuInfo["l1d cache"]!;
            lookupInfo.l1Cache = data.substring(0, data.indexOf("(")).trim().replaceFirst("MiB", "MB").replaceFirst("KiB", "KB");
            if (data.contains("${lookupInfo.coreCount} instance")) {
                lookupInfo.l1Cache += " (per core)";
            } else if (data.contains("${lookupInfo.threadCount} instance")) {
                lookupInfo.l1Cache += " (per thread)";
            } else if (data.contains("1 instance")) {
                lookupInfo.l1Cache += " (shared)";
            }
            final dSz = int.parse(lscpuInfo["l1d cache"]!.substring(0, lscpuInfo["l1d cache"]!.indexOf(" ")));
            final iSz = int.parse(lscpuInfo["l1i cache"]!.substring(0, lscpuInfo["l1i cache"]!.indexOf(" ")));
            lookupInfo.l1Cache = "${dSz + iSz}${lookupInfo.l1Cache.substring(lookupInfo.l1Cache.indexOf(" "))}";
        }

        // Virtualization Enabled
        if (lscpuInfo["flags"] != null) {
            if (lscpuInfo["flags"]!.contains("vmx") || lscpuInfo["flags"]!.contains("svm")) {
                lookupInfo.virtualization = true;
            }
        }

        lookupInfo.updateDynamicStats();

        return lookupInfo;
    }

    Future<void> updateDynamicStats() async {
        // update clock speed
        final cpuinfoFile = File("/proc/cpuinfo");
        final logicalCoreInfoStrings = (await cpuinfoFile.readAsString()).trimRight().split("\n\n");
        this.clockSpeed = 0.0;
        logicalCoreInfoStrings.forEach((logicalCoreInfo) {
            logicalCoreInfo.split("\n").forEach((propStr) {
                final colonIdx = propStr.indexOf(":");
                final propName = propStr.substring(0, colonIdx).trimRight();
                if (propName == "cpu MHz") {
                    this.clockSpeed += double.parse(propStr.substring(colonIdx + 2));
                }
            });
        });
        this.clockSpeed /= logicalCoreInfoStrings.length;

        // update utilization
        // https://www.linuxhowtos.org/System/procstat.htm
        final statFile = File("/proc/stat");
        final lines = statFile.readAsStringSync().split('\n');

        final cpuValues = lines[0].trimRight().split(" ");
        cpuValues.removeAt(0); // Remove the 'cpu' prefix
        List<int> currentCpuTimes = [];
        cpuValues.forEach((str) {
            if (str.isNotEmpty) {
                currentCpuTimes.add(int.parse(str));
            }
        });

        // total CPU time
        var currentTotal = 0;
        for (final value in currentCpuTimes) {
            currentTotal += value;
        }

        // idle CPU time
        final currentIdle = currentCpuTimes[3];

        if (_prevTotal == 0) {
            // First run, just store values for the next iteration
            _prevTotal = currentTotal;
            _prevIdle = currentIdle;
        } else {
            final diffIdle = currentIdle - _prevIdle;
            final diffTotal = currentTotal - _prevTotal;

            // Avoid division by zero if total hasn't changed (e.g., very fast checks or halted system)
            if (diffTotal > 0) {
                this.utilization = ((diffTotal - diffIdle) / diffTotal) * 100;
            } else {
                this.utilization = 0.0;
            }

            _prevTotal = currentTotal;
            _prevIdle = currentIdle;
        }

        // update utilization
        final uptimeFile = File("/proc/uptime");
        this.uptime = double.parse(uptimeFile.readAsStringSync().split(' ')[0]);

        // process count
        final processesDir = Directory("/proc/");
        final subdirs = processesDir.listSync();
        var runningProcessCount = 0;
        var runningThreadCount = 0;
        for (final subdir in subdirs) {
            final pathStr = subdir.path;
            if (int.tryParse(pathStr.substring("/proc/".length)) != null) {
                runningProcessCount++;

                // thread count
                try {
                    final procDir = Directory("${pathStr}/task");
                    runningThreadCount += procDir.listSync().length;
                } catch (e) {
                    // process no longer exists
                }
            }
        }
        this.runningProcessCount = runningProcessCount;
        this.runningThreadCount = runningThreadCount;
        
        // handles count
        final handlesResStr = Process.runSync("sysctl", ["fs.file-nr"]).stdout.toString();
        var idx = handlesResStr.indexOf("=");
        // find number
        while (true) {
            final chCode = handlesResStr.codeUnitAt(idx);
            if (chCode >= 48 && chCode <= 57) {
                break;
            }
            idx++;
        }
        final handlesStartIdx = idx;
        idx = handlesResStr.indexOf("\t", idx);
        this.handlesCount = int.parse(handlesResStr.substring(handlesStartIdx, idx));

    }

    String toString() {
        return """CPUInfo(
    name: ${this.name},
    coreCount: ${this.coreCount},
    threadCount: ${this.threadCount},
    baseClock: ${this.baseClock},
    boostClock: ${this.boostClock},
    l1Cache: ${this.l1Cache},
    l2Cache: ${this.l2Cache},
    l3Cache: ${this.l3Cache},
    tdp: ${this.tdp},
    iGPUName: ${this.iGPUName},
    iGPUCoreCount: ${this.iGPUCoreCount},
    iGPUClock: ${this.iGPUClock},
)""";
    }
}
