DROP PROCEDURE vol_getpcre;
EXECUTE PROCEDURE vol_getpcre('celaya','LP/15294/EXP/ES/2016-2211011585566075');

CREATE PROCEDURE vol_getpcre
(
	paramSvr      INT,
	paramPcre     CHAR(40)
)

RETURNING 
 INT;

DEFINE vcvepcre	INT;
LET vcvepcre = 0;

--ACAMBARO
IF paramSvr = 1  THEN  
	IF paramPcre matches 'LP/14260/DIST/PLA/2016*'	THEN
		LET vcvepcre = 1;
	END IF;
	IF paramPcre matches 'LP/14453/DIST/PLA/2016*'	THEN
		LET vcvepcre = 2;
	END IF;
	IF paramPcre matches 'LP/15468/EXP/ES/2016*'	THEN
		LET vcvepcre = 3;
	END IF;
	IF paramPcre matches 'LP/15796/EXP/ES/2016*'	THEN
		LET vcvepcre = 4;
	END IF;
	IF paramPcre matches 'LP/16511/EXP/ES/2016*'	THEN
		LET vcvepcre = 5;
	END IF;
	IF paramPcre matches 'LP/16534/EXP/ES/2016*'	THEN
		LET vcvepcre = 6;
	END IF;
	IF paramPcre matches 'LP/17327/EXP/ES/2016*'	THEN
		LET vcvepcre = 7;
	END IF;
	IF paramPcre matches 'LP/19715/EXP/ES/2016*'	THEN
		LET vcvepcre = 8;
	END IF;
	IF paramPcre matches 'LP/22294/EXP/ES/2019*'	THEN
		LET vcvepcre = 9;
	END IF;
END IF;    

--AGUASCALIENTES
IF paramSvr = 2  THEN  
	IF paramPcre matches 'LP/14674/DIST/PLA/2016*'	THEN
		LET vcvepcre = 10;
	END IF;
	IF paramPcre matches 'LP/16733/EXP/ES/2016*'	THEN
		LET vcvepcre = 11;
	END IF;
	IF paramPcre matches 'LP/17245/EXP/ES/2016*'	THEN
		LET vcvepcre = 12;
	END IF;
END IF;    

--ARANDAS
IF paramSvr = 3  THEN  
	IF paramPcre matches 'LP/14457/DIST/PLA/2016*'	THEN
		LET vcvepcre = 13;
	END IF;
	IF paramPcre matches 'LP/15339/EXP/ES/2016*'	THEN
		LET vcvepcre = 14;
	END IF;
	IF paramPcre matches 'LP/16150/EXP/ES/2016*'	THEN
		LET vcvepcre = 15;
	END IF;
	IF paramPcre matches 'LP/20087/EXP/ES/2017*'	THEN
		LET vcvepcre = 16;
	END IF;
	IF paramPcre matches 'LP/20594/EXP/ES/2017*'	THEN
		LET vcvepcre = 17;
	END IF;
	IF paramPcre matches 'LP/20976/EXP/ES/2018*'	THEN
		LET vcvepcre = 18;
	END IF;
	IF paramPcre matches 'LP/20977/EXP/ES/2018*'	THEN
		LET vcvepcre = 19;
	END IF;
	IF paramPcre matches 'LP/21252/EXP/ES/2018*'	THEN
		LET vcvepcre = 20;
	END IF;
	IF paramPcre matches 'LP/22108/EXP/ES/2019*'	THEN
		LET vcvepcre = 21;
	END IF;
END IF;   

-- CELAYA
IF paramSvr = 4  THEN
	IF paramPcre matches 'LP/14450/DIST/PLA/2016*'	THEN
		LET vcvepcre = 22;
	END IF;
	IF paramPcre matches 'LP/15352/EXP/ES/2016*'	THEN
		LET vcvepcre = 23;
	END IF;
	IF paramPcre matches 'LP/15442/EXP/ES/2016*'	THEN
		LET vcvepcre = 24;
	END IF;
	IF paramPcre matches 'LP/15781/EXP/ES/2016*'	THEN
		LET vcvepcre = 25;
	END IF;
	IF paramPcre matches 'LP/16136/EXP/ES/2016*'	THEN
		LET vcvepcre = 26;
	END IF;
	IF paramPcre matches 'LP/16507/EXP/ES/2016*'	THEN
		LET vcvepcre = 27;
	END IF;
	IF paramPcre matches 'LP/16814/EXP/ES/2016*'	THEN
		LET vcvepcre = 28;
	END IF;
	IF paramPcre matches 'LP/17821/EXP/ES/2016*'	THEN
		LET vcvepcre = 29;
	END IF;
	IF paramPcre matches 'LP/20088/EXP/ES/2017*'	THEN
		LET vcvepcre = 30;
	END IF;
	IF paramPcre matches 'LP/21632/EXP/ES/2018*'	THEN
		LET vcvepcre = 31;
	END IF;
	IF paramPcre matches 'LP/21949/EXP/ES/2018*'	THEN
		LET vcvepcre = 32;
	END IF;
	IF paramPcre matches 'LP/22292/EXP/ES/2019*'	THEN
		LET vcvepcre = 33;
	END IF;
	IF paramPcre matches 'LP/23106/EXP/ES/2020*'	THEN
		LET vcvepcre = 34;
	END IF;
END IF;

-- CULIACAN
IF paramSvr = 5  THEN  
	IF paramPcre matches 'LP/14494/DIST/PLA/2016*'	THEN
		LET vcvepcre = 35;
	END IF;
	IF paramPcre matches 'LP/16146/EXP/ES/2016*'	THEN
		LET vcvepcre = 36;
	END IF;
	IF paramPcre matches 'LP/16469/EXP/ES/2016*'	THEN
		LET vcvepcre = 37;
	END IF;
END IF;  

-- DOLORES
IF paramSvr = 6  THEN  
	IF paramPcre matches 'LP/14252/DIST/PLA/2016*'	THEN
		LET vcvepcre = 28;
	END IF;
	IF paramPcre matches 'LP/14254/DIST/PLA/2016*'	THEN
		LET vcvepcre = 39;
	END IF;
	IF paramPcre matches 'LP/14452/DIST/PLA/2016*'	THEN
		LET vcvepcre = 40;
	END IF;
	IF paramPcre matches 'LP/15469/EXP/ES/2016*'	THEN
		LET vcvepcre = 41;
	END IF;
	IF paramPcre matches 'LP/15470/EXP/ES/2016*'	THEN
		LET vcvepcre = 42;
	END IF;
	IF paramPcre matches 'LP/15855/EXP/ES/2016*'	THEN
		LET vcvepcre = 43;
	END IF;
	IF paramPcre matches 'LP/16979/EXP/ES/2016*'	THEN
		LET vcvepcre = 44;
	END IF;
	IF paramPcre matches 'LP/22780/EXP/ES/2019*'	THEN
		LET vcvepcre = 45;
	END IF;
END IF;   

-- GUADALAJARA
IF paramSvr = 7  THEN  
	IF paramPcre matches 'LP/14800/DIST/PLA/2016*'	THEN
		LET vcvepcre = 46;
	END IF;
	IF paramPcre matches 'LP/17766/EXP/ES/2016*'	THEN
		LET vcvepcre = 47;
	END IF;
END IF;   

-- GUAMUCHIL
IF paramSvr = 8  THEN  
	IF paramPcre matches 'LP/15683/EXP/ES/2016*'	THEN
		LET vcvepcre = 48;
	END IF;
END IF;   

-- IRAPUATO
IF paramSvr = 9  THEN  
	IF paramPcre matches 'LP/14447/DIST/PLA/2016*'	THEN
		LET vcvepcre = 49;
	END IF;
	IF paramPcre matches 'LP/14449/DIST/PLA/2016*'	THEN
		LET vcvepcre = 50;
	END IF;
	IF paramPcre matches 'LP/14455/DIST/PLA/2016*'	THEN
		LET vcvepcre = 51;
	END IF;
	IF paramPcre matches 'LP/15572/EXP/ES/2016*'	THEN
		LET vcvepcre = 52;
	END IF;
	IF paramPcre matches 'LP/15786/EXP/ES/2016*'	THEN
		LET vcvepcre = 53;
	END IF;
	IF paramPcre matches 'LP/15892/EXP/ES/2016*'	THEN
		LET vcvepcre = 54;
	END IF;
	IF paramPcre matches 'LP/15944/EXP/ES/2016*'	THEN
		LET vcvepcre = 55;
	END IF;
	IF paramPcre matches 'LP/16004/EXP/ES/2016*'	THEN
		LET vcvepcre = 56;
	END IF;
	IF paramPcre matches 'LP/16698/EXP/ES/2016*'	THEN
		LET vcvepcre = 57;
	END IF;
	IF paramPcre matches 'LP/17446/EXP/ES/2016*'	THEN
		LET vcvepcre = 58;
	END IF;
	IF paramPcre matches 'LP/14455/DIST/PLA/2016*'	THEN
		LET vcvepcre = 59;
	END IF;
	IF paramPcre matches 'LP/17534/EXP/ES/2016*'	THEN
		LET vcvepcre = 60;
	END IF;
	IF paramPcre matches 'LP/17653/EXP/ES/2016*'	THEN
		LET vcvepcre = 61;
	END IF;
	IF paramPcre matches 'LP/19061/EXP/ES/2016*'	THEN
		LET vcvepcre = 62;
	END IF;
	IF paramPcre matches 'LP/19716/EXP/ES/2016*'	THEN
		LET vcvepcre = 63;
	END IF;
	IF paramPcre matches 'LP/20595/EXP/ES/2017*'	THEN
		LET vcvepcre = 64;
	END IF;
END IF;     

-- LA PIEDAD
IF paramSvr = 10  THEN  
	IF paramPcre matches 'LP/14458/DIST/PLA/2016*'	THEN
		LET vcvepcre = 65;
	END IF;
	IF paramPcre matches 'LP/15358/EXP/ES/2016*'	THEN
		LET vcvepcre = 66;
	END IF;
	IF paramPcre matches 'LP/16102/EXP/ES/2016*'	THEN
		LET vcvepcre = 67;
	END IF;
	IF paramPcre matches 'LP/21045/EXP/ES/2018*'	THEN
		LET vcvepcre = 68;
	END IF;
	IF paramPcre matches 'LP/21047/EXP/ES/2018*'	THEN
		LET vcvepcre = 69;
	END IF;
	IF paramPcre matches 'LP/21574/EXP/ES/2018*'	THEN
		LET vcvepcre = 70;
	END IF;
	IF paramPcre matches 'LP/24569/EXP/ES/2022*'	THEN
		LET vcvepcre = 71;
	END IF;
END IF;     

-- LAZARO CARDENAS
IF paramSvr = 11  THEN  
	IF paramPcre matches 'LP/14461/DIST/PLA/2016*'	THEN
		LET vcvepcre = 72;
	END IF;
	IF paramPcre matches 'LP/15446/EXP/ES/2016*'	THEN
		LET vcvepcre = 73;
	END IF;
	IF paramPcre matches 'LP/16106/EXP/ES/2016*'	THEN
		LET vcvepcre = 74;
	END IF;
	IF paramPcre matches 'LP/16328/EXP/ES/2016*'	THEN
		LET vcvepcre = 75;
	END IF;
	IF paramPcre matches 'LP/17143/EXP/ES/2016*'	THEN
		LET vcvepcre = 76;
	END IF;
END IF;     

-- LEON
IF paramSvr = 12  THEN  
	IF paramPcre matches 'LP/14448/DIST/PLA/2016*'	THEN
		LET vcvepcre = 77;
	END IF;
	IF paramPcre matches 'LP/16435/EXP/ES/2016*'	THEN
		LET vcvepcre = 78;
	END IF;
	IF paramPcre matches 'LP/16458/EXP/ES/2016*'	THEN
		LET vcvepcre = 70;
	END IF;
	IF paramPcre matches 'LP/17034/EXP/ES/2016*'	THEN
		LET vcvepcre = 80;
	END IF;
END IF;   

-- MOCHIS
IF paramSvr = 13  THEN  
	IF paramPcre matches 'LP/14484/DIST/PLA/2016*'	THEN
		LET vcvepcre = 84;
	END IF;
	IF paramPcre matches 'LP/15749/EXP/ES/2016*'	THEN
		LET vcvepcre = 85;
	END IF;
	IF paramPcre matches 'LP/16647/EXP/ES/2016 *'	THEN
		LET vcvepcre = 86;
	END IF;
END IF;   

-- MONTERREY
IF paramSvr = 14  THEN  
	IF paramPcre matches 'LP/14481/DIST/PLA/2016*'	THEN
		LET vcvepcre = 87;
	END IF;
	IF paramPcre matches 'LP/15740/EXP/ES/2016*'	THEN
		LET vcvepcre = 88;
	END IF;
	IF paramPcre matches 'LP/15958/EXP/ES/2016*'	THEN
		LET vcvepcre = 89;
	END IF;
	IF paramPcre matches 'LP/16107/EXP/ES/2016*'	THEN
		LET vcvepcre = 90;
	END IF;
	IF paramPcre matches 'LP/16332/EXP/ES/2016*'	THEN
		LET vcvepcre = 91;
	END IF;
	IF paramPcre matches 'LP/16362/EXP/ES/2016*'	THEN
		LET vcvepcre = 92;
	END IF;
	IF paramPcre matches 'LP/16512/EXP/ES/2016*'	THEN
		LET vcvepcre = 93;
	END IF;
	IF paramPcre matches 'LP/16996/EXP/ES/2016*'	THEN
		LET vcvepcre = 94;
	END IF;
	IF paramPcre matches 'LP/17954/EXP/ES/2016*'	THEN
		LET vcvepcre = 95;
	END IF;
	IF paramPcre matches 'LP/17201/EXP/ES/2016*'	THEN
		LET vcvepcre = 193;
	END IF;
END IF;   

--MORELIA
IF paramSvr = 15  THEN  
	IF paramPcre matches 'LP/14259/DIST/PLA/2016*'	THEN
		LET vcvepcre = 96;
	END IF;
	IF paramPcre matches 'LP/14717/DIST/PLA/2016*'	THEN
		LET vcvepcre = 97;
	END IF;
	IF paramPcre matches 'LP/15294/EXP/ES/2016*'	THEN
		LET vcvepcre = 98;
	END IF;
	IF paramPcre matches 'LP/16107/EXP/ES/2016*'	THEN
		LET vcvepcre = 99;
	END IF;
	IF paramPcre matches 'LP/15912/EXP/ES/2016*'	THEN
		LET vcvepcre = 100;
	END IF;
	IF paramPcre matches 'LP/16428/EXP/ES/2016*'	THEN
		LET vcvepcre = 101;
	END IF;
	IF paramPcre matches 'LP/16467/EXP/ES/2016*'	THEN
		LET vcvepcre = 102;
	END IF;
	IF paramPcre matches 'LP/16629/EXP/ES/2016*'	THEN
		LET vcvepcre = 103;
	END IF;
	IF paramPcre matches 'LP/21192/EXP/ES/2018*'	THEN
		LET vcvepcre = 104;
	END IF;
	IF paramPcre matches 'LP/22521/EXP/ES/2019*'	THEN
		LET vcvepcre = 105;
	END IF;
END IF;  

-- MOROLEON
IF paramSvr = 16  THEN  
	IF paramPcre matches 'LP/14253/DIST/PLA/2016*'	THEN
		LET vcvepcre = 106;
	END IF;
	IF paramPcre matches 'LP/14258/DIST/PLA/2016*'	THEN
		LET vcvepcre = 107;
	END IF;
	IF paramPcre matches 'LP/14459/DIST/PLA/2016*'	THEN
		LET vcvepcre = 108;
	END IF;
	IF paramPcre matches 'LP/15910/EXP/ES/2016*'	THEN
		LET vcvepcre = 109;
	END IF;
	IF paramPcre matches 'LP/16397/EXP/ES/2016*'	THEN
		LET vcvepcre = 110;
	END IF;
	IF paramPcre matches 'LP/17621/EXP/ES/2016*'	THEN
		LET vcvepcre = 111;
	END IF;
	IF paramPcre matches 'LP/20975/EXP/ES/2018*'	THEN
		LET vcvepcre = 112;
	END IF;
	IF paramPcre matches 'LP/23105/EXP/ES/2020*'	THEN
		LET vcvepcre = 113;
	END IF;
END IF;   

-- MAZATLAN
IF paramSvr = 17  THEN  
	IF paramPcre matches 'LP/14483/DIST/PLA/2016*'	THEN
		LET vcvepcre = 81;
	END IF;
	IF paramPcre matches 'LP/15435/EXP/ES/2016*'	THEN
		LET vcvepcre = 82;
	END IF;
	IF paramPcre matches 'LP/15454/EXP/ES/2016*'	THEN
		LET vcvepcre = 83;
	END IF;
END IF;   

-- QUERETARO
IF paramSvr = 18  THEN  
	IF paramPcre matches 'LP/14462/DIST/PLA/2016*'	THEN
		LET vcvepcre = 114;
	END IF;
	IF paramPcre matches 'LP/14464/DIST/PLA/2016*'	THEN
		LET vcvepcre = 115;
	END IF;
	IF paramPcre matches 'LP/14465/DIST/PLA/2016*'	THEN
		LET vcvepcre = 116;
	END IF;
	IF paramPcre matches 'LP/14575/DIST/PLA/2016*'	THEN
		LET vcvepcre = 117;
	END IF;
	IF paramPcre matches 'LP/15322/EXP/ES/2016*'	THEN
		LET vcvepcre = 118;
	END IF;
	IF paramPcre matches 'LP/15452/EXP/ES/2016*'	THEN
		LET vcvepcre = 119;
	END IF;
	IF paramPcre matches 'LP/20975/EXP/ES/2018*'	THEN
		LET vcvepcre = 120;
	END IF;
	IF paramPcre matches 'LP/16373/EXP/ES/2016*'	THEN
		LET vcvepcre = 121;
	END IF;
	IF paramPcre matches 'LP/16982/EXP/ES/2016*'	THEN
		LET vcvepcre = 122;
	END IF;
	IF paramPcre matches 'LP/23615/DIST/PLA/2020*'	THEN
		LET vcvepcre = 123;
	END IF;
END IF;    

-- SALVATIERRA
IF paramSvr = 19 THEN  
	IF paramPcre matches 'LP/14451/DIST/PLA/2016*'	THEN
		LET vcvepcre = 124;
	END IF;
	IF paramPcre matches 'LP/19717/EXP/ES/2016*'	THEN
		LET vcvepcre = 125;
	END IF;
	IF paramPcre matches 'LP/20084/EXP/ES/2017*'	THEN
		LET vcvepcre = 126;
	END IF;
	IF paramPcre matches 'LP/22291/EXP/ES/2019*'	THEN
		LET vcvepcre = 127;
	END IF;
END IF;    

-- SAN JOSE ITURBIDE
IF paramSvr = 20 THEN  
	IF paramPcre matches 'LP/14229/DIST/PLA/2016*'	THEN
		LET vcvepcre = 128;
	END IF;
	IF paramPcre matches 'LP/14454/DIST/PLA/2016*'	THEN
		LET vcvepcre = 129;
	END IF;
	IF paramPcre matches 'LP/16342/EXP/ES/2016*'	THEN
		LET vcvepcre = 130;
	END IF;
	IF paramPcre matches 'LP/17163/EXP/ES/2016*'	THEN
		LET vcvepcre = 131;
	END IF;
	IF paramPcre matches 'LP/20979/EXP/ES/2018*'	THEN
		LET vcvepcre = 132;
	END IF;
	IF paramPcre matches 'LP/21048/EXP/ES/2018*'	THEN
		LET vcvepcre = 133;
	END IF;
	IF paramPcre matches 'LP/21049/EXP/ES/2018*'	THEN
		LET vcvepcre = 134;
	END IF;
	IF paramPcre matches 'LP/21254/EXP/ES/2018*'	THEN
		LET vcvepcre = 135;
	END IF;
END IF;     

-- SAN JUAN DEL RIO
IF paramSvr = 21 THEN  
	IF paramPcre matches 'LP/14286/DIST/PLA/2016*'	THEN
		LET vcvepcre = 136;
	END IF;
	IF paramPcre matches 'LP/14463/DIST/PLA/2016*'	THEN
		LET vcvepcre = 137;
	END IF;
	IF paramPcre matches 'LP/15347/EXP/ES/2016*'	THEN
		LET vcvepcre = 138;
	END IF;
	IF paramPcre matches 'LP/15462/EXP/ES/2016*'	THEN
		LET vcvepcre = 139;
	END IF;
	IF paramPcre matches 'LP/15694/EXP/ES/2016*'	THEN
		LET vcvepcre = 140;
	END IF;
	IF paramPcre matches 'LP/15695/EXP/ES/2016*'	THEN
		LET vcvepcre = 141;
	END IF;
	IF paramPcre matches 'LP/15696/EXP/ES/2016*'	THEN
		LET vcvepcre = 142;
	END IF;
	IF paramPcre matches 'LP/15941/EXP/ES/2016*'	THEN
		LET vcvepcre = 143;
	END IF;
	IF paramPcre matches 'LP/16207/EXP/ES/2016*'	THEN
		LET vcvepcre = 144;
	END IF;
	IF paramPcre matches 'LP/16269/EXP/ES/2016*'	THEN
		LET vcvepcre = 145;
	END IF;
	IF paramPcre matches 'LP/18248/EXP/AUT/2016*'	THEN
		LET vcvepcre = 146;
	END IF;
	IF paramPcre matches 'LP/20258/EXP/ES/2017*'	THEN
		LET vcvepcre = 147;
	END IF;
	IF paramPcre matches 'LP/20978/EXP/ES/2018*'	THEN
		LET vcvepcre = 148;
	END IF;
END IF;   

-- SAN LUIS POTOSI
IF paramSvr = 22 THEN  
	IF paramPcre matches 'LP/13932/DIST/PLA/2016*'	THEN
		LET vcvepcre = 149;
	END IF;
	IF paramPcre matches 'LP/16340/EXP/ES/2016*'	THEN
		LET vcvepcre = 150;
	END IF;
	IF paramPcre matches 'LP/16714/EXP/ES/2016*'	THEN
		LET vcvepcre = 151;
	END IF;
	IF paramPcre matches 'LP/17622/EXP/ES/2016*'	THEN
		LET vcvepcre = 152;
	END IF;
	IF paramPcre matches 'LP/21253/EXP/ES/2018*'	THEN
		LET vcvepcre = 153;
	END IF;
	IF paramPcre matches 'LP/22520/EXP/ES/2019*'	THEN
		LET vcvepcre = 154;
	END IF;
END IF;       

-- SAN MIGUEL DE ALLENDE
IF paramSvr = 23 THEN  
	IF paramPcre matches 'LP/14611/DIST/PLA/2016*'	THEN
		LET vcvepcre = 155;
	END IF;
	IF paramPcre matches 'LP/15940/EXP/ES/2016*'	THEN
		LET vcvepcre = 156;
	END IF;
END IF;       

-- TEPATITLAN  
IF paramSvr = 24 THEN  
	IF paramPcre matches 'LP/14518/DIST/PLA/2016*'	THEN
		LET vcvepcre = 157;
	END IF;
	IF paramPcre matches 'LP/15911/EXP/ES/2016*'	THEN
		LET vcvepcre = 158;
	END IF;
	IF paramPcre matches 'LP/16029/EXP/ES/2016*'	THEN
		LET vcvepcre = 159;
	END IF;
END IF;   

-- TULA
IF paramSvr = 25 THEN  
	IF paramPcre matches 'LP/14620/DIST/PLA/2016*'	THEN
		LET vcvepcre = 160;
	END IF;
	IF paramPcre matches 'LP/15987/EXP/ES/2016*'	THEN
		LET vcvepcre = 161;
	END IF;
END IF;    

-- URUAPAN
IF paramSvr = 26 THEN  
	IF paramPcre matches 'LP/14460/DIST/PLA/2016*'	THEN
		LET vcvepcre = 162;
	END IF;
	IF paramPcre matches 'LP/15447/EXP/ES/2016*'	THEN
		LET vcvepcre = 163;
	END IF;
	IF paramPcre matches 'LP/16441/EXP/ES/2016*'	THEN
		LET vcvepcre = 164;
	END IF;
	IF paramPcre matches 'LP/17336/EXP/ES/2016*'	THEN
		LET vcvepcre = 165;
	END IF;
	IF paramPcre matches 'LP/17337/EXP/ES/2016*'	THEN
		LET vcvepcre = 166;
	END IF;
	IF paramPcre matches 'LP/17785/EXP/ES/2016*'	THEN
		LET vcvepcre = 167;
	END IF;
	IF paramPcre matches 'LP/20085/EXP/ES/2017*'	THEN
		LET vcvepcre = 168;
	END IF;
	IF paramPcre matches 'LP/20259/EXP/ES/2017*'	THEN
		LET vcvepcre = 169;
	END IF;
	IF paramPcre matches 'LP/21751/EXP/ES/2018*'	THEN
		LET vcvepcre = 170;
	END IF;
	IF paramPcre matches 'LP/23104/EXP/ES/2020*'	THEN
		LET vcvepcre = 171;
	END IF;
	IF paramPcre matches 'LP/23107/EXP/ES/2020*'	THEN
		LET vcvepcre = 172;
	END IF;
	IF paramPcre matches 'LP/23108/EXP/ES/2020*'	THEN
		LET vcvepcre = 173;
	END IF;
END IF;   

-- VERACRUZ    
IF paramSvr = 27 THEN  
	IF paramPcre matches 'LP/14466/DIST/PLA/2016*'	THEN
		LET vcvepcre = 174;
	END IF;
	IF paramPcre matches 'LP/14468/DIST/PLA/2016*'	THEN
		LET vcvepcre = 175;
	END IF;
	IF paramPcre matches 'LP/15927/EXP/ES/2016*'	THEN
		LET vcvepcre = 176;
	END IF;
	IF paramPcre matches 'LP/16202/EXP/ES/2016*'	THEN
		LET vcvepcre = 177;
	END IF;
	IF paramPcre matches 'LP/16819/EXP/ES/2016*'	THEN
		LET vcvepcre = 178;
	END IF;
	IF paramPcre matches 'LP/20086/EXP/ES/2017*'	THEN
		LET vcvepcre = 179;
	END IF;
	IF paramPcre matches 'LP/21084/EXP/ES/2018*'	THEN
		LET vcvepcre = 180;
	END IF;
	IF paramPcre matches 'LP/21633/EXP/ES/2018'	THEN
		LET vcvepcre = 181;
	END IF;
	IF paramPcre matches 'LP/22296/EXP/ES/2019*'	THEN
		LET vcvepcre = 182;
	END IF;
END IF; 

-- XALAPA  
IF paramSvr = 28 THEN  
	IF paramPcre matches 'LP/14467/DIST/PLA/2016*'	THEN
		LET vcvepcre = 183;
	END IF;
	IF paramPcre matches 'LP/15895/EXP/ES/2016*'	THEN
		LET vcvepcre = 184;
	END IF;
	IF paramPcre matches 'LP/15976/EXP/ES/2016*'	THEN
		LET vcvepcre = 185;
	END IF;
	IF paramPcre matches 'LP/16919/EXP/ES/2016*'	THEN
		LET vcvepcre = 186;
	END IF;
	IF paramPcre matches 'LP/20596/EXP/ES/2017*'	THEN
		LET vcvepcre = 187;
	END IF;
	IF paramPcre matches 'LP/20980/EXP/ES/2018*'	THEN
		LET vcvepcre = 188;
	END IF;
	IF paramPcre matches 'LP/21046/EXP/ES/2018*'	THEN
		LET vcvepcre = 189;
	END IF;
	IF paramPcre matches 'LP/21468/EXP/ES/2018'	THEN
		LET vcvepcre = 190;
	END IF;
	IF paramPcre matches 'LP/21573/EXP/ES/2018*'	THEN
		LET vcvepcre = 191;
	END IF;
	IF paramPcre matches 'LP/21753/EXP/ES/2018*'	THEN
		LET vcvepcre = 192;
	END IF;
END IF;                                                                                                                                                                                                                                                                                                                                                   
                  
RETURN 	vcvepcre;
END PROCEDURE; 

