#Pink Salmon Fry Emergence Degree-Day Data.

##########################
# Beacham & Murray 1986a #
##########################


#Quinsam
Days4 = rnorm(n = 2288, mean = 194, sd = 3.5)
Quinsam4 = rnorm(n = 2288, mean = 4.1, sd = 0.24) * Days4
Days8 = rnorm(n = 1790, mean = 119.2, sd = 0.8)
Quinsam8 = rnorm(n = 1790, mean = 8, sd = 0.23) * Days8
Days12 = rnorm(n = 1983, mean = 90.2, sd = 2.4)
Quinsam12 = rnorm(n = 1983, mean = 12, sd = 0.29) * Days12
Q = data.frame(Location = "Quinsam", Treatment = as.character(c(rep(4,2288),rep(8,1790),rep(12,1983))), Days.to.Emergence = c(Days4,Days8,Days12), Degree.Days = c(Quinsam4,Quinsam8,Quinsam12), Northing = 552211, Easting = 1049459, Source = "Beacham & Murray 1986a")

#Puntledge
Days8 = rnorm(n = 766, mean = 123.4, sd = 0.5)
Puntledge8 = rnorm(n = 766, mean = 8, sd = 0.23) * Days8
Days12 = rnorm(n = 955, mean = 91.8, sd = 1)
Puntledge12 = rnorm(n = 955, mean = 12, sd = 0.29) * Days12
P = data.frame(Location = "Puntledge", Treatment = as.character(c(rep(8,766),rep(12,955))), Days.to.Emergence = c(Days8,Days12), Degree.Days = c(Puntledge8,Puntledge12), Northing = 518945, Easting = 1068357, Source = "Beacham & Murray 1986a")

#Keogh
Days4 = rnorm(n = 2228, mean = 191, sd = 4.8)
Keogh4 = rnorm(n = 2228, mean = 4.1, sd = 0.24) * Days4
Days8 = rnorm(n = 1708, mean = 121, sd = 2.6)
Keogh8 = rnorm(n = 1708, mean = 8, sd = 0.22) * Days8
Days12 = rnorm(n = 1926, mean = 91.2, sd = 2.2)
Keogh12 = rnorm(n = 1926, mean = 12, sd = 0.28) * Days12
K= data.frame(Location = "Keogh", Treatment = as.character(c(rep(4,2228),rep(8,1708),rep(12,1926))), Days.to.Emergence = c(Days4,Days8,Days12), Degree.Days = c(Keogh4,Keogh8,Keogh12), Northing = 623077, Easting = 909028, Source = "Beacham & Murray 1986a")

#Jones
Days4 = rnorm(n = 1078, mean = 193.6, sd = 2.9)
Jones4 = rnorm(n = 1078, mean = 4.1, sd = 0.25) * Days4
Days8 = rnorm(n = 1493, mean = 120.5, sd = 1.6)
Jones8 = rnorm(n = 1493, mean = 8, sd = 0.22) * Days8
Days12 = rnorm(n = 1222, mean = 87.7, sd = 1.1)
Jones12 = rnorm(n = 1222, mean = 12, sd = 0.26) * Days12
J= data.frame(Location = "Jones", Treatment = as.character(c(rep(4,1078),rep(8,1493),rep(12,1222))), Days.to.Emergence = c(Days4,Days8,Days12), Degree.Days = c(Jones4,Jones8,Jones12), Northing = 490342, Easting = 1322438, Source = "Beacham & Murray 1986a")

#Coquihalla
Days8 = rnorm(n = 786, mean = 120.3, sd = 2.6)
Coq8 = rnorm(n = 786, mean = 8, sd = 0.24) * Days8
Days12 = rnorm(n = 922, mean = 88.4, sd = 1.4)
Coq12 = rnorm(n = 922, mean = 12, sd = 0.26) * Days12
C= data.frame(Location = "Coquihalla", Treatment = as.character(c(rep(8,786),rep(12,922))), Days.to.Emergence = c(Days8,Days12), Degree.Days = c(Coq8,Coq12), Northing = 508685, Easting = 1349678, Source = "Beacham & Murray 1986a")


##########################
# Murray & Beacham 1986a #
##########################

#Chilliwack
Days.to.Emergence = 124.1
n = 222
Temp.V = sort(rep(seq(5,14,0.5),3),decreasing = T)
Degree.Days = rnorm(n,sum(c(Temp.V,rep(5,round(Days.to.Emergence-length(Temp.V))))),0)
Chilli_T1 = data.frame(Location = "Vedder/Chilliwack", Treatment = "14-5-5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Murray & Beacham 1986a")

Days.to.Emergence = 98.4
n = 191
Temp.V = sort(rep(seq(5,14,0.5),3),decreasing = F)
Degree.Days = rnorm(n,sum(c(Temp.V,rep(14,Days.to.Emergence-length(Temp.V)))),0)
Chilli_T2 = data.frame(Location = "Vedder/Chilliwack", Treatment = "5-14-14", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Murray & Beacham 1986a")

Days.to.Emergence = 160.7
n = 205
Degree.Days = rnorm(n,sum(c(rep(5,Days.to.Emergence))),0)
Chilli_T3 = data.frame(Location = "Vedder/Chilliwack", Treatment = "5-5-5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Murray & Beacham 1986a")

Days.to.Emergence = 287
n = 172
Temp.V = sort(rep(seq(2,5,0.5),3),decreasing = T)
Degree.Days = rnorm(n,sum(c(Temp.V,rep(2,Days.to.Emergence-length(Temp.V)))),0)
Chilli_T4 = data.frame(Location = "Vedder/Chilliwack", Treatment = "5-2-2", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Murray & Beacham 1986a")

Days.to.Emergence = 96.5
n = 228
Temp.V = c(sort(rep(seq(6,15,0.5),3),decreasing = T),sort(rep(seq(6.5,15,0.5),3),decreasing = F))
if(length(Temp.V)<Days.to.Emergence){
	Degree.Days = rnorm(n,sum(c(Temp.V,rep(15,Days.to.Emergence-length(Temp.V)))),0)
} else Degree.Days = rnorm(n, sum(Temp.V[1:round(Days.to.Emergence)]),0)
Chilli_T5 = data.frame(Location = "Vedder/Chilliwack", Treatment = "16-6-15", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Murray & Beacham 1986a")

Days.to.Emergence = 113.8
n = 204
Temp.V = c(sort(rep(seq(6,11,0.5),3),decreasing = T),sort(rep(seq(6.5,15,0.5),3),decreasing = F))
if(length(Temp.V)<Days.to.Emergence){
	Degree.Days = rnorm(n,sum(c(Temp.V,rep(15,Days.to.Emergence-length(Temp.V)))),0)
} else Degree.Days = rnorm(n, sum(Temp.V[1:round(Days.to.Emergence)]),0)
Chilli_T6 = data.frame(Location = "Vedder/Chilliwack", Treatment = "11-6-15", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Murray & Beacham 1986a")

Days.to.Emergence = 126.3
n = 228
Temp.V = c(sort(rep(seq(4,11,0.5),3),decreasing = T),sort(rep(seq(4.5,15,0.5),3),decreasing = F))
if(length(Temp.V)<Days.to.Emergence){
	Degree.Days = rnorm(n,sum(c(Temp.V,rep(15,Days.to.Emergence-length(Temp.V)))),0)
} else Degree.Days = rnorm(n, sum(Temp.V[1:round(Days.to.Emergence)]),0)
Chilli_T7 = data.frame(Location = "Vedder/Chilliwack", Treatment = "11-4-15", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Murray & Beacham 1986a")

Days.to.Emergence = 134.4
n = 222
Temp.V = c(sort(rep(seq(2,11,0.5),3),decreasing = T),sort(rep(seq(2.5,15,0.5),3),decreasing = F))
if(length(Temp.V)<Days.to.Emergence){
	Degree.Days = rnorm(n,sum(c(Temp.V,rep(15,Days.to.Emergence-length(Temp.V)))),0)
} else Degree.Days = rnorm(n,sum(Temp.V[1:round(Days.to.Emergence)]),0)
Chilli_T8 = data.frame(Location = "Vedder/Chilliwack", Treatment = "11-2-15", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Murray & Beacham 1986a")

##########################
# Beacham & Murray 1987a #
##########################
Stage3 = 17; Stage4 = 24; Stage5 = 47

#Khutzeymateen
n = 89 * 0.892
Days.to.Emergence = 258
Degree.Days = rnorm(n,8,0.4)*Stage3 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage3)
Khut_3 = data.frame(Location = "Khutzeymateen", Treatment = "8-2_3", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1071128, Easting = 756084, Source = "Beacham & Murray 1987a")

n = 65 * 0.941
Days.to.Emergence = 235
Degree.Days = rnorm(n,8,0.4)*Stage4 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage4)
Khut_4 = data.frame(Location = "Khutzeymateen", Treatment = "8-2_4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1071128, Easting = 756084, Source = "Beacham & Murray 1987a")

n = 66 * 1
Days.to.Emergence = 217
Degree.Days = rnorm(n,8,0.4)*Stage5 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage5)
Degree.Days = rep((Stage5*8) + (2 * (Days.to.Emergence-Stage5)),n)
Khut_5 = data.frame(Location = "Khutzeymateen", Treatment = "8-2_5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1071128, Easting = 756084, Source = "Beacham & Murray 1987a")

#Quaal
n = 176 * 0.888
Days.to.Emergence = rnorm(n,251.5,2.1)
Degree.Days = rnorm(n,8,0.4)*Stage3 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage3)
Quaal_3 = data.frame(Location = "Quaal", Treatment = "8-2_3", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1987a")

n = 65 * 0.941
Days.to.Emergence = rnorm(n, 233,1.4)
Degree.Days = rnorm(n,8,0.4)*Stage4 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage4)
Quaal_4 = data.frame(Location = "Quaal", Treatment = "8-2_4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1987a")

n = 66 * 1
Days.to.Emergence = rnorm(n, 214,0)
Degree.Days = rnorm(n,8,0.4)*Stage5 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage5)
Quaal_5 = data.frame(Location = "Quaal", Treatment = "8-2_5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1987a")

#Babine
n = 81 * 0.88
Days.to.Emergence = rnorm(n,248.5,0.7)
Degree.Days = rnorm(n,8,0.4)*Stage3 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage3)
Babine_3 = data.frame(Location = "Babine", Treatment = "8-2_3", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1148007, Easting = 959953, Source = "Beacham & Murray 1987a")

n = 97 * 0.924
Days.to.Emergence = rnorm(n,237.5,4.9)
Degree.Days = rnorm(n,8,0.4)*Stage4 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage4)
Babine_4 = data.frame(Location = "Babine", Treatment = "8-2_4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1148007, Easting = 959953, Source = "Beacham & Murray 1987a")

n = 66 * 1
Days.to.Emergence = rnorm(n,207,2.8)
Degree.Days = rnorm(n,8,0.4)*Stage5 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage5)
Babine_5 = data.frame(Location = "Babine", Treatment = "8-2_5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1148007, Easting = 959953, Source = "Beacham & Murray 1987a")

#Kitwanga
n = 71 * 0.562
Days.to.Emergence = rnorm(n,253,2.8)
Degree.Days = rnorm(n,8,0.4)*Stage3 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage3)
Kitwanga_3 = data.frame(Location = "Kitwanga", Treatment = "8-2_3", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1137046, Easting = 869765, Source = "Beacham & Murray 1987a")

n = 114 * 0.858
Days.to.Emergence = rnorm(n,237.5,4.9)
Degree.Days = rnorm(n,8,0.4)*Stage4 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage4)
Kitwanga_4 = data.frame(Location = "Kitwanga", Treatment = "8-2_4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1137046, Easting = 869765, Source = "Beacham & Murray 1987a")

n = 138 * 0.964
Days.to.Emergence = rnorm(n,208,2.8)
Degree.Days = rnorm(n,8,0.4)*Stage5 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage5)
Kitwanga_5 = data.frame(Location = "Kitwanga", Treatment = "8-2_5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1137046, Easting = 869765, Source = "Beacham & Murray 1987a")

#Atnarko
n = 266 * 0.673
Days.to.Emergence = rnorm(n,245,2.8)
Degree.Days = rnorm(n,8,0.4)*Stage3 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage3)
Atnarko_3 = data.frame(Location = "Atnarko", Treatment = "8-2_3", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1987a")

n = 378 * 0.959
Days.to.Emergence = rnorm(n,235.5,2.1)
Degree.Days = rnorm(n,8,0.4)*Stage4 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage4)
Atnarko_4 = data.frame(Location = "Atnarko", Treatment = "8-2_4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1987a")

n = 357 * 0.899
Days.to.Emergence = rnorm(n,204,2.8)
Degree.Days = rnorm(n,8,0.4)*Stage5 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage5)
Atnarko_5 = data.frame(Location = "Atnarko", Treatment = "8-2_5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1987a")

#Deena
n = 243 * 0.788
Days.to.Emergence = rnorm(n,250,0.7)
Degree.Days = rnorm(n,8,0.4)*Stage3 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage3)
Deena_3 = data.frame(Location = "Deena", Treatment = "8-2_3", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 918866, Easting = 588265, Source = "Beacham & Murray 1987a")

n = 256 * 0.952
Days.to.Emergence = rnorm(n,244,2.1)
Degree.Days = rnorm(n,8,0.4)*Stage4 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage4)
Deena_4 = data.frame(Location = "Deena", Treatment = "8-2_4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 918866, Easting = 588265, Source = "Beacham & Murray 1987a")

n = 307 * 0.837
Days.to.Emergence = rnorm(n,209,2.8)
Degree.Days = rnorm(n,8,0.4)*Stage5 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage5)
Deena_5 = data.frame(Location = "Deena", Treatment = "8-2_5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 918866, Easting = 588265, Source = "Beacham & Murray 1987a")

#Yakoun
n = 73 * 1
Days.to.Emergence = rnorm(n,248,0)
Degree.Days = rnorm(n,8,0.4)*Stage3 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage3)
Yakoun_3 = data.frame(Location = "Yakoun", Treatment = "8-2_3", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 957877, Easting = 586133, Source = "Beacham & Murray 1987a")

n = 105 * 1
Days.to.Emergence = rnorm(n,235,0)
Degree.Days = rnorm(n,8,0.4)*Stage4 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage4)
Yakoun_4 = data.frame(Location = "Yakoun", Treatment = "8-2_4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 957877, Easting = 586133, Source = "Beacham & Murray 1987a")

n = 104 * 1
Days.to.Emergence = rnorm(n,206,0)
Degree.Days = rnorm(n,8,0.4)*Stage5 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage5)
Yakoun_5 = data.frame(Location = "Yakoun", Treatment = "8-2_5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 957877, Easting = 586133, Source = "Beacham & Murray 1987a")

#Waukwaas
n = 262 * 0.745
Days.to.Emergence = rnorm(n,251,0)
Degree.Days = rnorm(n,8,0.4)*Stage3 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage3)
Waukwaas_3 = data.frame(Location = "Waukwaas", Treatment = "8-2_3", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 615548, Easting = 904585, Source = "Beacham & Murray 1987a")

n = 367 * 0.963
Days.to.Emergence = rnorm(n,238,0)
Degree.Days = rnorm(n,8,0.4)*Stage4 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage4)
Waukwaas_4 = data.frame(Location = "Waukwaas", Treatment = "8-2_4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 615548, Easting = 904585, Source = "Beacham & Murray 1987a")

n = 359 * 0.983
Days.to.Emergence = rnorm(n,206,0)
Degree.Days = rnorm(n,8,0.4)*Stage5 + rnorm(n,2.2,0.4)*(Days.to.Emergence-Stage5)
Waukwaas_5 = data.frame(Location = "Waukwaas", Treatment = "8-2_5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 615548, Easting = 904585, Source = "Beacham & Murray 1987a")

#########################
# Beacham & Murray 1988 #
#########################

#Even Year Pinks.

#Khutzeymateen
n = 547 * 0.973
Days.to.Emergence = rnorm(n,201.1,3.2)
Degree.Days = rnorm(n,4.1,0.76) * Days.to.Emergence
Khut88_1 = data.frame(Location = "Khutzeymateen", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1071128, Easting = 756084, Source = "Beacham & Murray 1988")

n = 693 * 0.990
Days.to.Emergence = rnorm(n,132,4.8)
Degree.Days = rnorm(n,8.1,0.39) * Days.to.Emergence
Khut88_2 = data.frame(Location = "Khutzeymateen", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1071128, Easting = 756084, Source = "Beacham & Murray 1988")

n = 729 * 0.965
Days.to.Emergence = rnorm(n,103.3,4.4)
Degree.Days = rnorm(n,12,0.37) * Days.to.Emergence
Khut88_3 = data.frame(Location = "Khutzeymateen", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1071128, Easting = 756084, Source = "Beacham & Murray 1988")

#Quaal
n = 785 * 0.952
Days.to.Emergence = rnorm(n,201.9,6.9)
Degree.Days = rnorm(n,4.1,0.72)*Days.to.Emergence
Quaal88_1 = data.frame(Location = "Quaal", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1988")

n = 869 * 0.980
Days.to.Emergence = rnorm(n,131,6.1)
Degree.Days = rnorm(n,8.1,0.39)*Days.to.Emergence
Quaal88_2 = data.frame(Location = "Quaal", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1988")

n = 940 * 0.895
Days.to.Emergence = rnorm(n,101,2.1)
Degree.Days = rnorm(n,12.1,0.36)*Days.to.Emergence
Quaal88_3 = data.frame(Location = "Quaal", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1988")

#Babine
n = 657 * 0.8
Days.to.Emergence = rnorm(n,200.1,7.3)
Degree.Days = rnorm(n,4.1,0.38)*Days.to.Emergence
Babine88_1 = data.frame(Location = "Babine", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1148007, Easting = 959953, Source = "Beacham & Murray 1988")

n = 949 * 0.969
Days.to.Emergence = rnorm(n,129.4,8.3)
Degree.Days = rnorm(n,8.1,0.35)*Days.to.Emergence
Babine88_2 = data.frame(Location = "Babine", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1148007, Easting = 959953, Source = "Beacham & Murray 1988")

n = 983 * 0.923
Days.to.Emergence = rnorm(n,99.5,6.6)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Babine88_3 = data.frame(Location = "Babine", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1148007, Easting = 959953, Source = "Beacham & Murray 1988")

#Kitwanga
n = 197 * 0.931
Days.to.Emergence = rnorm(n,201,0)
Degree.Days = rnorm(n,4.1,0.38)*Days.to.Emergence
Kitwanga88_1 = data.frame(Location = "Kitwanga", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1137046, Easting = 869765, Source = "Beacham & Murray 1988")

n = 194 * 0.980
Days.to.Emergence = rnorm(n,130.6,0)
Degree.Days = rnorm(n,8.1,0.35)*Days.to.Emergence
Kitwanga88_2 = data.frame(Location = "Kitwanga", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1137046, Easting = 869765, Source = "Beacham & Murray 1988")

n = 190 * 0.974
Days.to.Emergence = rnorm(n,98,0)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Kitwanga88_3 = data.frame(Location = "Kitwanga", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1137046, Easting = 869765, Source = "Beacham & Murray 1988")

#Atnarko
n = 1188 * 0.434
Days.to.Emergence = rnorm(n,196.8,0.8)
Degree.Days = rnorm(n,4.1,0.39)*Days.to.Emergence
Atnarko88_1 = data.frame(Location = "Atnarko", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1988")

n = 1770 * 0.940
Days.to.Emergence = rnorm(n,136.4,1.2)
Degree.Days = rnorm(n,8.1,0.36)*Days.to.Emergence
Atnarko88_2 = data.frame(Location = "Atnarko", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1988")

n = 1577 * 0.954
Days.to.Emergence = rnorm(n,94.9,4.1)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Atnarko88_3 = data.frame(Location = "Atnarko", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1988")

#Deena
n = 1075 * 0.280
Days.to.Emergence = rnorm(n,197.3,1.7)
Degree.Days = rnorm(n,4.1,0.4)*Days.to.Emergence
Deena88_1 = data.frame(Location = "Deena", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 918866, Easting = 588265, Source = "Beacham & Murray 1988")

n = 1764 * 0.983
Days.to.Emergence = rnorm(n,130.4,7.5)
Degree.Days = rnorm(n,8.1,0.36)*Days.to.Emergence
Deena88_2 = data.frame(Location = "Deena", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 918866, Easting = 588265, Source = "Beacham & Murray 1988")

n = 1577 * 0.954
Days.to.Emergence = rnorm(n,94.9,4.1)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Deena88_3 = data.frame(Location = "Deena", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 918866, Easting = 588265, Source = "Beacham & Murray 1988")

#Yakoun
n = 1016 * 0.674
Days.to.Emergence = rnorm(n,205.2,3.9)
Degree.Days = rnorm(n,4.1,0.4)*Days.to.Emergence
Yakoun88_1 = data.frame(Location = "Yakoun", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 957877, Easting = 586133, Source = "Beacham & Murray 1988")

n = 1291 * 0.975
Days.to.Emergence = rnorm(n,132,3.5)
Degree.Days = rnorm(n,8.1,0.36)*Days.to.Emergence
Yakoun88_2 = data.frame(Location = "Yakoun", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 957877, Easting = 586133, Source = "Beacham & Murray 1988")

n = 1176 * 0.975
Days.to.Emergence = rnorm(n,97.5,3.2)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Yakoun88_3 = data.frame(Location = "Yakoun", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 957877, Easting = 586133, Source = "Beacham & Murray 1988")

#Quinsam
n = 817 * 0.505
Days.to.Emergence = rnorm(n,203,2.1)
Degree.Days = rnorm(n,4.1,0.41)*Days.to.Emergence
Q88_1 = data.frame(Location = "Quinsam", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham & Murray 1988")

n = 1643 * 0.951
Days.to.Emergence = rnorm(n,121.8,1.9)
Degree.Days = rnorm(n,8.1,0.37)*Days.to.Emergence
Q88_2 = data.frame(Location = "Quinsam", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham & Murray 1988")

n = 1800 * 0.956
Days.to.Emergence = rnorm(n,96.2,1.5)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Q88_3 = data.frame(Location = "Quinsam", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham & Murray 1988")

#Keogh
n = 700 * 0.641
Days.to.Emergence = rnorm(n,198.6, 2.1)
Degree.Days = rnorm(n,4.1,0.41)*Days.to.Emergence
K88_1 = data.frame(Location = "Keogh", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 623077, Easting = 909028, Source = "Beacham & Murray 1988")

n = 1213 * 0.988
Days.to.Emergence = rnorm(n,125.7, 3.2)
Degree.Days = rnorm(n,8.1,0.37)*Days.to.Emergence
K88_2 = data.frame(Location = "Keogh", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 623077, Easting = 909028, Source = "Beacham & Murray 1988")

n = 1138 * 0.948
Days.to.Emergence = rnorm(n,97.4, 5.2)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
K88_3 = data.frame(Location = "Keogh", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 623077, Easting = 909028, Source = "Beacham & Murray 1988")

#Waukwaas
n = 1035 * 0.533
Days.to.Emergence = rnorm(n,200.3,4.1)
Degree.Days = rnorm(n,4.1,0.41)*Days.to.Emergence
Waukwaas88_1 = data.frame(Location = "Waukwaas", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 615548, Easting = 904585, Source = "Beacham & Murray 1988")

n = 1252 * 0.982
Days.to.Emergence = rnorm(n,121.8,3)
Degree.Days = rnorm(n,8.1,0.37)*Days.to.Emergence
Waukwaas88_2 = data.frame(Location = "Waukwaas", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 615548, Easting = 904585, Source = "Beacham & Murray 1988")

n = 2081 * 0.967
Days.to.Emergence = rnorm(n,97.4,5.2)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Waukwaas88_3 = data.frame(Location = "Waukwaas", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 615548, Easting = 904585, Source = "Beacham & Murray 1988")

#Beacham & Murray 1988 Odd Year Pinks.

#Quaal
n = 690 * 0.610
Days.to.Emergence = rnorm(n,197,2.6)
Degree.Days = rnorm(n,4.1,0.36)*Days.to.Emergence
Quaal88_1Odd = data.frame(Location = "Quaal", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1988")

n = 940 * 0.996
Days.to.Emergence = rnorm(n,122.1,2.3)
Degree.Days = rnorm(n,8,0.36)*Days.to.Emergence
Quaal88_2Odd = data.frame(Location = "Quaal", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1988")

n = 934 * 0.988
Days.to.Emergence = rnorm(n,90,3.5)
Degree.Days = rnorm(n,12.1,0.41)*Days.to.Emergence
Quaal88_3Odd = data.frame(Location = "Quaal", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 971540, Easting = 776942, Source = "Beacham & Murray 1988")

#Dogfish (Not sure about the lat/long)
n = 1310 * 0.803
Days.to.Emergence = rnorm(n,200.1,4.9)
Degree.Days = rnorm(n,4.1,0.37)*Days.to.Emergence
Dog88_1Odd = data.frame(Location = "Dogfish", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 744080, Easting = 1283092, Source = "Beacham & Murray 1988")

n = 1442 * 0.995
Days.to.Emergence = rnorm(n,127.6,2.5)
Degree.Days = rnorm(n,8,0.33)*Days.to.Emergence
Dog88_2Odd = data.frame(Location = "Dogfish", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 744080, Easting = 1283092, Source = "Beacham & Murray 1988")

n = 1566 * 0.989
Days.to.Emergence = rnorm(n,94.7,0.6)
Degree.Days = rnorm(n,12,0.37)*Days.to.Emergence
Dog88_3Odd = data.frame(Location = "Dogfish", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 744080, Easting = 1283092, Source = "Beacham & Murray 1988")

#Kitimat
n = 543 * 0.658
Days.to.Emergence = rnorm(n,204.8,3.2)
Degree.Days = rnorm(n,4.1,0.35)*Days.to.Emergence
Kit88_1Odd = data.frame(Location = "Kitimat", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1029845, Easting = 843712, Source = "Beacham & Murray 1988")

n = 914 * 0.987
Days.to.Emergence = rnorm(n,127.8,1.6)
Degree.Days = rnorm(n,8,0.3)*Days.to.Emergence
Kit88_2Odd = data.frame(Location = "Kitimat", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1029845, Easting = 843712, Source = "Beacham & Murray 1988")

n = 895 * 0.953
Days.to.Emergence = rnorm(n,94.5,0.6)
Degree.Days = rnorm(n,12,0.38)*Days.to.Emergence
Kit88_3Odd = data.frame(Location = "Kitimat", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1029845, Easting = 843712, Source = "Beacham & Murray 1988")

#Kitsumkalum
n = 1379 * 0.921
Days.to.Emergence = rnorm(n,202.5,1.7)
Degree.Days = rnorm(n,4.1,0.31)*Days.to.Emergence
Kitsum88_1Odd = data.frame(Location = "Kitsumkalum", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1084667, Easting = 821489, Source = "Beacham & Murray 1988")

n = 1379 * 0.940
Days.to.Emergence = rnorm(n,125.9,1.6)
Degree.Days = rnorm(n,8,0.23)*Days.to.Emergence
Kitsum88_2Odd = data.frame(Location = "Kitsumkalum", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1084667, Easting = 821489, Source = "Beacham & Murray 1988")

n = 1485 * 0.951
Days.to.Emergence = rnorm(n,90.8,0.3)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Kitsum88_3Odd = data.frame(Location = "Kitsumkalum", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1084667, Easting = 821489, Source = "Beacham & Murray 1988")

#Kitwanga
n = 903 * 0.912
Days.to.Emergence = rnorm(n,201,0.6)
Degree.Days = rnorm(n,4.1,0.31)*Days.to.Emergence
Kitwanga88_1Odd = data.frame(Location = "Kitwanga", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1142912, Easting = 869083, Source = "Beacham & Murray 1988")

n = 1120 * 0.988
Days.to.Emergence = rnorm(n,127,2.4)
Degree.Days = rnorm(n,8,0.23)*Days.to.Emergence
Kitwanga88_2Odd = data.frame(Location = "Kitwanga", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1142912, Easting = 869083, Source = "Beacham & Murray 1988")

n = 980 * 0.996
Days.to.Emergence = rnorm(n,92,1.5)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Kitwanga88_3Odd = data.frame(Location = "Kitwanga", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 1142912, Easting = 869083, Source = "Beacham & Murray 1988")

#Kainet
n = 1076 * 0.670
Days.to.Emergence = rnorm(n,197.8,1.6)
Degree.Days = rnorm(n,4.1,0.32)*Days.to.Emergence
Kainet88_1Odd = data.frame(Location = "Kainet", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 865425, Easting = 875648, Source = "Beacham & Murray 1988")

n = 1859 * 0.991
Days.to.Emergence = rnorm(n,125.7,1.8)
Degree.Days = rnorm(n,8,0.23)*Days.to.Emergence
Kainet88_2Odd = data.frame(Location = "Kainet", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 865425, Easting = 875648, Source = "Beacham & Murray 1988")

n = 1847 * 0.982
Days.to.Emergence = rnorm(n,93.2,0.7)
Degree.Days = rnorm(n,12,0.37)*Days.to.Emergence
Kainet88_3Odd = data.frame(Location = "Kainet", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 865425, Easting = 875648, Source = "Beacham & Murray 1988")

#Atnarko
n = 704 * 0.956
Days.to.Emergence = rnorm(n,198.2,3)
Degree.Days = rnorm(n,4.1,0.32)*Days.to.Emergence
Atnarko88_Odd1 = data.frame(Location = "Atnarko", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1988")

n = 1407 * 0.989
Days.to.Emergence = rnorm(n,124.9,1.1)
Degree.Days = rnorm(n,8,0.24)*Days.to.Emergence
Atnarko88_Odd2 = data.frame(Location = "Atnarko", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1988")

n = 1528 * 0.985
Days.to.Emergence = rnorm(n,93.6,1.6)
Degree.Days = rnorm(n,12,0.36)*Days.to.Emergence
Atnarko88_Odd3 = data.frame(Location = "Atnarko", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 798395, Easting = 1019893, Source = "Beacham & Murray 1988")

#Quinsam
n = 883 * 0.333
Days.to.Emergence = rnorm(n,194.3,4.3)
Degree.Days = rnorm(n,4.1,0.31)*Days.to.Emergence
Q88_Odd1 = data.frame(Location = "Quinsam", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham & Murray 1988")

n = 2147 * 0.975
Days.to.Emergence = rnorm(n,122.8,1)
Degree.Days = rnorm(n,8,0.23)*Days.to.Emergence
Q88_Odd2 = data.frame(Location = "Quinsam", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham & Murray 1988")

n = 2312 * 0.948
Days.to.Emergence = rnorm(n,91.8,1.3)
Degree.Days = rnorm(n,12,0.35)*Days.to.Emergence
Q88_Odd3 = data.frame(Location = "Quinsam", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham & Murray 1988")

#Vedder/Chilliwack
n = 854 * 0.508
Days.to.Emergence = rnorm(n,192.4,4.9)
Degree.Days = rnorm(n,4.1,0.29)*Days.to.Emergence
Vedder88_Odd1 = data.frame(Location = "Vedder/Chilliwack", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Beacham & Murray 1988")

n = 1442 * 0.974
Days.to.Emergence = rnorm(n,120.1,1.1)
Degree.Days = rnorm(n,8.1,0.54)*Days.to.Emergence
Vedder88_Odd2 = data.frame(Location = "Vedder/Chilliwack", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Beacham & Murray 1988")

n = 1557 * 0.976
Days.to.Emergence = rnorm(n,86,0.6)
Degree.Days = rnorm(n,12,0.43)*Days.to.Emergence
Vedder88_Odd3 = data.frame(Location = "Vedder/Chilliwack", Treatment = "12", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 459824, Easting = 1303027, Source = "Beacham & Murray 1988")


################
# Beacham 1988 #
################

#Quinsam
n = 44
Days.to.Emergence = rnorm(n,201.1,3.2)
Degree.Days = rnorm(n,4.1,0.3)*Days.to.Emergence
Q87_1 = data.frame(Location = "Quinsam", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham 1988")

n = 50
Days.to.Emergence = rnorm(n,124.8,1.1)
Degree.Days = rnorm(n,8,0.2)*Days.to.Emergence
Q87_2 = data.frame(Location = "Quinsam", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham 1988")

n = 46
Days.to.Emergence = rnorm(n,81.8,2)
Degree.Days = rnorm(n,15.9,0.7)*Days.to.Emergence
Q87_3 = data.frame(Location = "Quinsam", Treatment = "16", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 552211, Easting = 1049459, Source = "Beacham 1988")

#Harrison
n = 30
Days.to.Emergence = rnorm(n,191.1,3.9)
Degree.Days = rnorm(n,4.1,0.3)*Days.to.Emergence
H87_1 = data.frame(Location = "Harrison", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 481775, Easting = 1297825, Source = "Beacham 1988")

n = 50
Days.to.Emergence = rnorm(n,123.2,1.5)
Degree.Days = rnorm(n,8,0.2)*Days.to.Emergence
H87_2 = data.frame(Location = "Harrison", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 481775, Easting = 1297825, Source = "Beacham 1988")

n = 50
Days.to.Emergence = rnorm(n,81.7,1.2)
Degree.Days = rnorm(n,15.9,0.7)*Days.to.Emergence
H87_3 = data.frame(Location = "Harrison", Treatment = "16", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 481775, Easting = 1297825, Source = "Beacham 1988")

#########################
# Murray & McPhail 1987 #
#########################

n = 229 * 0.22
Days.to.Emergence = rnorm(n,72.1,0)
Degree.Days = rnorm(n,13.9,0.94)*Days.to.Emergence
Vedder87_1 = data.frame(Location = "Vedder/Chilliwack", Treatment = "14", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 463919, Easting = 1329835, Source = "Murray & McPhail 1987")

n = 219 * 0.84
Days.to.Emergence = rnorm(n,90.8,0)
Degree.Days = rnorm(n,11.2,0.98)*Days.to.Emergence
Vedder87_2 = data.frame(Location = "Vedder/Chilliwack", Treatment = "11", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 463919, Easting = 1329835, Source = "Murray & McPhail 1987")

n = 203 * 0.97
Days.to.Emergence = rnorm(n,120.2,0)
Degree.Days = rnorm(n,8.1,0.85)*Days.to.Emergence
Vedder87_3 = data.frame(Location = "Vedder/Chilliwack", Treatment = "8", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 463919, Easting = 1329835, Source = "Murray & McPhail 1987")

n = 211 * 0.94
Days.to.Emergence = rnorm(n,173.2,0)
Degree.Days = rnorm(n,5.1,0.78)*Days.to.Emergence
Vedder87_4 = data.frame(Location = "Vedder/Chilliwack", Treatment = "5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 463919, Easting = 1329835, Source = "Murray & McPhail 1987")

################
# Brannon 1987 #
################

#Sweltzer Creek
Degree.Days = 820
Days.to.Emergence = Degree.Days/4.4
Sweltzer1 = data.frame(Location = "Sweltzer", Treatment = "4", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 456139, Easting = 1293101, Source = "Brannon 1987")

Degree.Days = 925
Days.to.Emergence = Degree.Days/5.6
Sweltzer2 = data.frame(Location = "Sweltzer", Treatment = "5", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 456139, Easting = 1293101, Source = "Brannon 1987")

Degree.Days = 1000
Days.to.Emergence = Degree.Days/6.7
Sweltzer3 = data.frame(Location = "Sweltzer", Treatment = "7", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 456139, Easting = 1293101, Source = "Brannon 1987")

Degree.Days = 1080
Days.to.Emergence = Degree.Days/8.9
Sweltzer4 = data.frame(Location = "Sweltzer", Treatment = "9", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 456139, Easting = 1293101, Source = "Brannon 1987")

Degree.Days = 1220
Days.to.Emergence = Degree.Days/11.1
Sweltzer5 = data.frame(Location = "Sweltzer", Treatment = "11", Days.to.Emergence = Days.to.Emergence, Degree.Days = Degree.Days, Northing = 456139, Easting = 1293101, Source = "Brannon 1987")


#Data Combination.
########################################################################################
library(tidyverse)
final = bind_rows(Q,P,K,J,C,Chilli_T1,Chilli_T2,Chilli_T3,Chilli_T4,Chilli_T5,Chilli_T6,Chilli_T7, Chilli_T8, Q87_1, Q87_2, Q87_3, H87_1, H87_2, H87_3, Khut_3, Khut_4, Khut_5, Quaal_3, Quaal_4, Quaal_5, Babine_3, Babine_4, Babine_5, Kitwanga_3, Kitwanga_4, Kitwanga_5, Atnarko_3, Atnarko_4, Atnarko_5, Deena_3, Deena_4, Deena_5, Yakoun_3, Yakoun_4, Yakoun_5, Waukwaas_3, Waukwaas_4, Waukwaas_5, Khut88_1,Khut88_2,Khut_5,Quaal88_1,Quaal88_2,Quaal88_3, Babine88_1, Babine88_2, Babine88_3, Kitwanga88_1, Kitwanga88_2, Kitwanga88_3, Atnarko88_1, Atnarko88_2, Atnarko88_3, Deena88_1, Deena88_2, Deena88_3, Yakoun88_1, Yakoun88_2,Yakoun88_3, Q88_1, Q88_2, Q88_3, K88_1, K88_2, K88_3, Waukwaas88_1, Waukwaas88_2, Waukwaas88_3, Quaal88_1Odd, Quaal88_2Odd, Quaal88_3Odd, Dog88_1Odd, Dog88_2Odd, Dog88_3Odd, Kit88_1Odd, Kit88_2Odd, Kit88_3Odd, Kitsum88_1Odd, Kitsum88_2Odd, Kitsum88_3Odd, Kainet88_1Odd, Kainet88_2Odd, Kainet88_3Odd, Atnarko88_Odd1, Atnarko88_Odd2, Atnarko88_Odd3, Q88_Odd1, Q88_Odd2, Q88_Odd3, Vedder88_Odd1, Vedder88_Odd2, Vedder88_Odd3, Vedder87_1, Vedder87_2, Vedder87_3, Vedder87_4, Sweltzer5, Sweltzer4, Sweltzer3, Sweltzer2, Sweltzer1)
final$Location = as.factor(final$Location)
final$Treatment = as.factor(final$Treatment)

saveRDS(final, file = "Data_03_Emergence.rds")


library(nlme); library(rstan); library(tidyverse)
#Set Up MultiCore Processing for Stan.
rstan_options(auto_write = TRUE)
options(mc.cores = 7)

dat = readRDS("Data_03_Emergence.rds")

simple = dat %>% group_by(Treatment,Location,Source) %>% 
	summarize(Degree.Days = mean(Degree.Days), Days.to.Emergence = mean(Days.to.Emergence)) %>% 
	ungroup()
simple = simple %>% mutate(DD_center = Degree.Days-mean(Degree.Days))

simple = dat %>% select(Location, Treatment, Source, Northing, Easting) %>% distinct() %>% left_join(simple, ., by = c("Location","Treatment","Source"))

mod = gls(model = Days.to.Emergence~DD_center, data = simple, weights = varExp(form = ~DD_center))

dat.list = list(N = nrow(simple),
		 x = simple$Degree.Days,
		 y = simple$Days.to.Emergence)
fit = stan(file = "03_StanMod.stan", data = dat.list,
					 iter = 20000, chains = 4, warmup = 8000, thin = 3)
save(fit, file = "stanMod.RData")
print(fit, digits = 4)
summary(mod)
stan_dens(fit)
traceplot(fit)