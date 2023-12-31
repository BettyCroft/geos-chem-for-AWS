! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
! Auxiliary Routines File
!
! Generated by KPP-2.3.3_gc symbolic chemistry Kinetics PreProcessor
!       (http://www.cs.vt.edu/~asandu/Software/KPP)
! KPP is distributed under GPL, the general public licence
!       (http://www.gnu.org/copyleft/gpl.html)
! (C) 1995-1997, V. Damian & A. Sandu, CGRER, Univ. Iowa
! (C) 1997-2005, A. Sandu, Michigan Tech, Virginia Tech
!     With important contributions from:
!        M. Damian, Villanova University, USA
!        R. Sander, Max-Planck Institute for Chemistry, Mainz, Germany
!
! File                 : gckpp_Util.F90
! Equation file        : gckpp.kpp
! Output root filename : gckpp
!
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE gckpp_Util

  USE gckpp_Parameters
  IMPLICIT NONE

CONTAINS



! User INLINED Utility Functions

! End INLINED Utility Functions

! Utility Functions from KPP_HOME/util/util
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
! UTIL - Utility functions
!   Arguments :
!
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

! ****************************************************************
!
! InitSaveData - Opens the data file for writing
!   Parameters :
!
! ****************************************************************

      SUBROUTINE InitSaveData ()

      USE gckpp_Parameters

      open(10, file='gckpp.dat')

      END SUBROUTINE InitSaveData

! End of InitSaveData function
! ****************************************************************

! ****************************************************************
!
! SaveData - Write LOOKAT species in the data file
!   Parameters :
!
! ****************************************************************

      SUBROUTINE SaveData ()

      USE gckpp_Global
      USE gckpp_Monitor

      INTEGER i

      WRITE(10,999) (TIME-TSTART)/3600.D0,  &
                   (C(LOOKAT(i))/CFACTOR, i=1,NLOOKAT)
999   FORMAT(E24.16,100(1X,E24.16))

      END SUBROUTINE SaveData

! End of SaveData function
! ****************************************************************

! ****************************************************************
!
! CloseSaveData - Close the data file
!   Parameters :
!
! ****************************************************************

      SUBROUTINE CloseSaveData ()

      USE gckpp_Parameters

      CLOSE(10)

      END SUBROUTINE CloseSaveData

! End of CloseSaveData function
! ****************************************************************

! ****************************************************************
!
! GenerateMatlab - Generates MATLAB file to load the data file
!   Parameters :
!                It will have a character string to prefix each
!                species name with.
!
! ****************************************************************

      SUBROUTINE GenerateMatlab ( PREFIX )

      USE gckpp_Parameters
      USE gckpp_Global
      USE gckpp_Monitor


      CHARACTER(LEN=8) PREFIX
      INTEGER i

      open(20, file='gckpp.m')
      write(20,*) 'load gckpp.dat;'
      write(20,990) PREFIX
990   FORMAT(A1,'c = gckpp;')
      write(20,*) 'clear gckpp;'
      write(20,991) PREFIX, PREFIX
991   FORMAT(A1,'t=',A1,'c(:,1);')
      write(20,992) PREFIX
992   FORMAT(A1,'c(:,1)=[];')

      do i=1,NLOOKAT
        write(20,993) PREFIX, SPC_NAMES(LOOKAT(i)), PREFIX, i
993     FORMAT(A1,A6,' = ',A1,'c(:,',I2,');')
      end do

      CLOSE(20)

      END SUBROUTINE GenerateMatlab

! End of GenerateMatlab function
! ****************************************************************


! End Utility Functions from KPP_HOME/util/util
! End of UTIL function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
! Shuffle_user2kpp - function to copy concentrations from USER to KPP
!   Arguments :
!      V_USER    - Concentration of variable species in USER's order
!      V         - Concentrations of variable species (local)
!
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SUBROUTINE Shuffle_user2kpp ( V_USER, V )

! V_USER - Concentration of variable species in USER's order
  REAL(kind=dp) :: V_USER(NVAR)
! V - Concentrations of variable species (local)
  REAL(kind=dp) :: V(NVAR)

  V(234) = V_USER(1)
  V(219) = V_USER(2)
  V(209) = V_USER(3)
  V(4) = V_USER(4)
  V(262) = V_USER(5)
  V(115) = V_USER(6)
  V(5) = V_USER(7)
  V(181) = V_USER(8)
  V(156) = V_USER(9)
  V(146) = V_USER(10)
  V(250) = V_USER(11)
  V(193) = V_USER(12)
  V(257) = V_USER(13)
  V(101) = V_USER(14)
  V(63) = V_USER(15)
  V(157) = V_USER(16)
  V(189) = V_USER(17)
  V(107) = V_USER(18)
  V(274) = V_USER(19)
  V(125) = V_USER(20)
  V(134) = V_USER(21)
  V(52) = V_USER(22)
  V(173) = V_USER(23)
  V(271) = V_USER(24)
  V(12) = V_USER(25)
  V(272) = V_USER(26)
  V(273) = V_USER(27)
  V(178) = V_USER(28)
  V(71) = V_USER(29)
  V(98) = V_USER(30)
  V(59) = V_USER(31)
  V(76) = V_USER(32)
  V(158) = V_USER(33)
  V(123) = V_USER(34)
  V(143) = V_USER(35)
  V(144) = V_USER(36)
  V(53) = V_USER(37)
  V(54) = V_USER(38)
  V(55) = V_USER(39)
  V(56) = V_USER(40)
  V(57) = V_USER(41)
  V(58) = V_USER(42)
  V(72) = V_USER(43)
  V(75) = V_USER(44)
  V(1) = V_USER(45)
  V(2) = V_USER(46)
  V(3) = V_USER(47)
  V(264) = V_USER(48)
  V(259) = V_USER(49)
  V(103) = V_USER(50)
  V(44) = V_USER(51)
  V(228) = V_USER(52)
  V(102) = V_USER(53)
  V(47) = V_USER(54)
  V(187) = V_USER(55)
  V(77) = V_USER(56)
  V(78) = V_USER(57)
  V(285) = V_USER(58)
  V(194) = V_USER(59)
  V(79) = V_USER(60)
  V(232) = V_USER(61)
  V(263) = V_USER(62)
  V(286) = V_USER(63)
  V(104) = V_USER(64)
  V(261) = V_USER(65)
  V(6) = V_USER(66)
  V(112) = V_USER(67)
  V(92) = V_USER(68)
  V(132) = V_USER(69)
  V(206) = V_USER(70)
  V(68) = V_USER(71)
  V(119) = V_USER(72)
  V(89) = V_USER(73)
  V(108) = V_USER(74)
  V(177) = V_USER(75)
  V(214) = V_USER(76)
  V(110) = V_USER(77)
  V(233) = V_USER(78)
  V(218) = V_USER(79)
  V(174) = V_USER(80)
  V(60) = V_USER(81)
  V(48) = V_USER(82)
  V(49) = V_USER(83)
  V(287) = V_USER(84)
  V(191) = V_USER(85)
  V(247) = V_USER(86)
  V(284) = V_USER(87)
  V(190) = V_USER(88)
  V(82) = V_USER(89)
  V(83) = V_USER(90)
  V(84) = V_USER(91)
  V(85) = V_USER(92)
  V(270) = V_USER(93)
  V(208) = V_USER(94)
  V(69) = V_USER(95)
  V(86) = V_USER(96)
  V(87) = V_USER(97)
  V(175) = V_USER(99)
  V(235) = V_USER(100)
  V(106) = V_USER(101)
  V(275) = V_USER(102)
  V(251) = V_USER(103)
  V(267) = V_USER(104)
  V(223) = V_USER(105)
  V(133) = V_USER(106)
  V(188) = V_USER(108)
  V(118) = V_USER(109)
  V(184) = V_USER(110)
  V(122) = V_USER(111)
  V(126) = V_USER(112)
  V(127) = V_USER(113)
  V(168) = V_USER(114)
  V(266) = V_USER(115)
  V(141) = V_USER(116)
  V(45) = V_USER(117)
  V(50) = V_USER(118)
  V(41) = V_USER(119)
  V(73) = V_USER(120)
  V(171) = V_USER(121)
  V(192) = V_USER(122)
  V(100) = V_USER(123)
  V(237) = V_USER(124)
  V(147) = V_USER(125)
  V(203) = V_USER(126)
  V(109) = V_USER(127)
  V(128) = V_USER(128)
  V(139) = V_USER(129)
  V(230) = V_USER(130)
  V(164) = V_USER(131)
  V(165) = V_USER(132)
  V(161) = V_USER(133)
  V(240) = V_USER(134)
  V(145) = V_USER(135)
  V(129) = V_USER(136)
  V(224) = V_USER(137)
  V(130) = V_USER(138)
  V(225) = V_USER(139)
  V(116) = V_USER(140)
  V(216) = V_USER(141)
  V(137) = V_USER(142)
  V(138) = V_USER(143)
  V(211) = V_USER(144)
  V(241) = V_USER(145)
  V(242) = V_USER(146)
  V(217) = V_USER(147)
  V(186) = V_USER(148)
  V(182) = V_USER(149)
  V(180) = V_USER(150)
  V(185) = V_USER(151)
  V(124) = V_USER(152)
  V(7) = V_USER(153)
  V(61) = V_USER(154)
  V(244) = V_USER(155)
  V(243) = V_USER(156)
  V(179) = V_USER(157)
  V(148) = V_USER(158)
  V(268) = V_USER(159)
  V(99) = V_USER(160)
  V(200) = V_USER(161)
  V(229) = V_USER(162)
  V(88) = V_USER(163)
  V(8) = V_USER(164)
  V(9) = V_USER(165)
  V(220) = V_USER(166)
  V(163) = V_USER(167)
  V(149) = V_USER(168)
  V(210) = V_USER(169)
  V(239) = V_USER(170)
  V(253) = V_USER(171)
  V(10) = V_USER(172)
  V(11) = V_USER(173)
  V(169) = V_USER(174)
  V(221) = V_USER(175)
  V(13) = V_USER(176)
  V(14) = V_USER(177)
  V(15) = V_USER(178)
  V(16) = V_USER(179)
  V(19) = V_USER(180)
  V(20) = V_USER(181)
  V(23) = V_USER(182)
  V(22) = V_USER(183)
  V(24) = V_USER(184)
  V(25) = V_USER(185)
  V(245) = V_USER(186)
  V(204) = V_USER(187)
  V(135) = V_USER(188)
  V(246) = V_USER(189)
  V(70) = V_USER(190)
  V(260) = V_USER(191)
  V(131) = V_USER(192)
  V(160) = V_USER(193)
  V(196) = V_USER(194)
  V(172) = V_USER(195)
  V(226) = V_USER(196)
  V(202) = V_USER(197)
  V(140) = V_USER(198)
  V(222) = V_USER(199)
  V(90) = V_USER(200)
  V(231) = V_USER(201)
  V(265) = V_USER(202)
  V(215) = V_USER(203)
  V(46) = V_USER(204)
  V(176) = V_USER(205)
  V(197) = V_USER(206)
  V(136) = V_USER(207)
  V(150) = V_USER(208)
  V(74) = V_USER(209)
  V(27) = V_USER(210)
  V(151) = V_USER(211)
  V(152) = V_USER(212)
  V(248) = V_USER(213)
  V(117) = V_USER(214)
  V(166) = V_USER(215)
  V(183) = V_USER(216)
  V(227) = V_USER(217)
  V(238) = V_USER(218)
  V(201) = V_USER(219)
  V(153) = V_USER(220)
  V(64) = V_USER(221)
  V(62) = V_USER(222)
  V(170) = V_USER(223)
  V(18) = V_USER(224)
  V(42) = V_USER(225)
  V(43) = V_USER(226)
  V(279) = V_USER(227)
  V(281) = V_USER(228)
  V(283) = V_USER(229)
  V(207) = V_USER(230)
  V(91) = V_USER(231)
  V(17) = V_USER(232)
  V(278) = V_USER(233)
  V(269) = V_USER(234)
  V(276) = V_USER(235)
  V(111) = V_USER(238)
  V(65) = V_USER(239)
  V(277) = V_USER(240)
  V(93) = V_USER(241)
  V(213) = V_USER(242)
  V(212) = V_USER(243)
  V(249) = V_USER(244)
  V(66) = V_USER(245)
  V(120) = V_USER(246)
  V(236) = V_USER(247)
  V(121) = V_USER(248)
  V(205) = V_USER(249)
  V(113) = V_USER(250)
  V(51) = V_USER(251)
  V(198) = V_USER(252)
  V(195) = V_USER(253)
  V(252) = V_USER(254)
  V(114) = V_USER(255)
  V(105) = V_USER(256)
  V(254) = V_USER(257)
  V(199) = V_USER(258)
  V(256) = V_USER(259)
  V(94) = V_USER(260)
  V(95) = V_USER(261)
  V(96) = V_USER(262)
  V(258) = V_USER(263)
  V(255) = V_USER(264)
  V(154) = V_USER(265)
  V(159) = V_USER(266)
  V(167) = V_USER(267)
  V(162) = V_USER(268)
  V(155) = V_USER(269)
  V(97) = V_USER(270)
  V(280) = V_USER(271)
  V(282) = V_USER(272)
  V(142) = V_USER(277)
  V(67) = V_USER(278)
  V(28) = V_USER(279)
  V(29) = V_USER(280)
  V(30) = V_USER(281)
  V(31) = V_USER(282)
  V(32) = V_USER(284)
  V(33) = V_USER(285)
  V(80) = V_USER(286)
  V(21) = V_USER(287)

END SUBROUTINE Shuffle_user2kpp

! End of Shuffle_user2kpp function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
! Shuffle_kpp2user - function to restore concentrations from KPP to USER
!   Arguments :
!      V         - Concentrations of variable species (local)
!      V_USER    - Concentration of variable species in USER's order
!
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SUBROUTINE Shuffle_kpp2user ( V, V_USER )

! V - Concentrations of variable species (local)
  REAL(kind=dp) :: V(NVAR)
! V_USER - Concentration of variable species in USER's order
  REAL(kind=dp) :: V_USER(NVAR)

  V_USER(1) = V(234)
  V_USER(2) = V(219)
  V_USER(3) = V(209)
  V_USER(4) = V(4)
  V_USER(5) = V(262)
  V_USER(6) = V(115)
  V_USER(7) = V(5)
  V_USER(8) = V(181)
  V_USER(9) = V(156)
  V_USER(10) = V(146)
  V_USER(11) = V(250)
  V_USER(12) = V(193)
  V_USER(13) = V(257)
  V_USER(14) = V(101)
  V_USER(15) = V(63)
  V_USER(16) = V(157)
  V_USER(17) = V(189)
  V_USER(18) = V(107)
  V_USER(19) = V(274)
  V_USER(20) = V(125)
  V_USER(21) = V(134)
  V_USER(22) = V(52)
  V_USER(23) = V(173)
  V_USER(24) = V(271)
  V_USER(25) = V(12)
  V_USER(26) = V(272)
  V_USER(27) = V(273)
  V_USER(28) = V(178)
  V_USER(29) = V(71)
  V_USER(30) = V(98)
  V_USER(31) = V(59)
  V_USER(32) = V(76)
  V_USER(33) = V(158)
  V_USER(34) = V(123)
  V_USER(35) = V(143)
  V_USER(36) = V(144)
  V_USER(37) = V(53)
  V_USER(38) = V(54)
  V_USER(39) = V(55)
  V_USER(40) = V(56)
  V_USER(41) = V(57)
  V_USER(42) = V(58)
  V_USER(43) = V(72)
  V_USER(44) = V(75)
  V_USER(45) = V(1)
  V_USER(46) = V(2)
  V_USER(47) = V(3)
  V_USER(48) = V(264)
  V_USER(49) = V(259)
  V_USER(50) = V(103)
  V_USER(51) = V(44)
  V_USER(52) = V(228)
  V_USER(53) = V(102)
  V_USER(54) = V(47)
  V_USER(55) = V(187)
  V_USER(56) = V(77)
  V_USER(57) = V(78)
  V_USER(58) = V(285)
  V_USER(59) = V(194)
  V_USER(60) = V(79)
  V_USER(61) = V(232)
  V_USER(62) = V(263)
  V_USER(63) = V(286)
  V_USER(64) = V(104)
  V_USER(65) = V(261)
  V_USER(66) = V(6)
  V_USER(67) = V(112)
  V_USER(68) = V(92)
  V_USER(69) = V(132)
  V_USER(70) = V(206)
  V_USER(71) = V(68)
  V_USER(72) = V(119)
  V_USER(73) = V(89)
  V_USER(74) = V(108)
  V_USER(75) = V(177)
  V_USER(76) = V(214)
  V_USER(77) = V(110)
  V_USER(78) = V(233)
  V_USER(79) = V(218)
  V_USER(80) = V(174)
  V_USER(81) = V(60)
  V_USER(82) = V(48)
  V_USER(83) = V(49)
  V_USER(84) = V(287)
  V_USER(85) = V(191)
  V_USER(86) = V(247)
  V_USER(87) = V(284)
  V_USER(88) = V(190)
  V_USER(89) = V(82)
  V_USER(90) = V(83)
  V_USER(91) = V(84)
  V_USER(92) = V(85)
  V_USER(93) = V(270)
  V_USER(94) = V(208)
  V_USER(95) = V(69)
  V_USER(96) = V(86)
  V_USER(97) = V(87)
  V_USER(99) = V(175)
  V_USER(100) = V(235)
  V_USER(101) = V(106)
  V_USER(102) = V(275)
  V_USER(103) = V(251)
  V_USER(104) = V(267)
  V_USER(105) = V(223)
  V_USER(106) = V(133)
  V_USER(108) = V(188)
  V_USER(109) = V(118)
  V_USER(110) = V(184)
  V_USER(111) = V(122)
  V_USER(112) = V(126)
  V_USER(113) = V(127)
  V_USER(114) = V(168)
  V_USER(115) = V(266)
  V_USER(116) = V(141)
  V_USER(117) = V(45)
  V_USER(118) = V(50)
  V_USER(119) = V(41)
  V_USER(120) = V(73)
  V_USER(121) = V(171)
  V_USER(122) = V(192)
  V_USER(123) = V(100)
  V_USER(124) = V(237)
  V_USER(125) = V(147)
  V_USER(126) = V(203)
  V_USER(127) = V(109)
  V_USER(128) = V(128)
  V_USER(129) = V(139)
  V_USER(130) = V(230)
  V_USER(131) = V(164)
  V_USER(132) = V(165)
  V_USER(133) = V(161)
  V_USER(134) = V(240)
  V_USER(135) = V(145)
  V_USER(136) = V(129)
  V_USER(137) = V(224)
  V_USER(138) = V(130)
  V_USER(139) = V(225)
  V_USER(140) = V(116)
  V_USER(141) = V(216)
  V_USER(142) = V(137)
  V_USER(143) = V(138)
  V_USER(144) = V(211)
  V_USER(145) = V(241)
  V_USER(146) = V(242)
  V_USER(147) = V(217)
  V_USER(148) = V(186)
  V_USER(149) = V(182)
  V_USER(150) = V(180)
  V_USER(151) = V(185)
  V_USER(152) = V(124)
  V_USER(153) = V(7)
  V_USER(154) = V(61)
  V_USER(155) = V(244)
  V_USER(156) = V(243)
  V_USER(157) = V(179)
  V_USER(158) = V(148)
  V_USER(159) = V(268)
  V_USER(160) = V(99)
  V_USER(161) = V(200)
  V_USER(162) = V(229)
  V_USER(163) = V(88)
  V_USER(164) = V(8)
  V_USER(165) = V(9)
  V_USER(166) = V(220)
  V_USER(167) = V(163)
  V_USER(168) = V(149)
  V_USER(169) = V(210)
  V_USER(170) = V(239)
  V_USER(171) = V(253)
  V_USER(172) = V(10)
  V_USER(173) = V(11)
  V_USER(174) = V(169)
  V_USER(175) = V(221)
  V_USER(176) = V(13)
  V_USER(177) = V(14)
  V_USER(178) = V(15)
  V_USER(179) = V(16)
  V_USER(180) = V(19)
  V_USER(181) = V(20)
  V_USER(182) = V(23)
  V_USER(183) = V(22)
  V_USER(184) = V(24)
  V_USER(185) = V(25)
  V_USER(186) = V(245)
  V_USER(187) = V(204)
  V_USER(188) = V(135)
  V_USER(189) = V(246)
  V_USER(190) = V(70)
  V_USER(191) = V(260)
  V_USER(192) = V(131)
  V_USER(193) = V(160)
  V_USER(194) = V(196)
  V_USER(195) = V(172)
  V_USER(196) = V(226)
  V_USER(197) = V(202)
  V_USER(198) = V(140)
  V_USER(199) = V(222)
  V_USER(200) = V(90)
  V_USER(201) = V(231)
  V_USER(202) = V(265)
  V_USER(203) = V(215)
  V_USER(204) = V(46)
  V_USER(205) = V(176)
  V_USER(206) = V(197)
  V_USER(207) = V(136)
  V_USER(208) = V(150)
  V_USER(209) = V(74)
  V_USER(210) = V(27)
  V_USER(211) = V(151)
  V_USER(212) = V(152)
  V_USER(213) = V(248)
  V_USER(214) = V(117)
  V_USER(215) = V(166)
  V_USER(216) = V(183)
  V_USER(217) = V(227)
  V_USER(218) = V(238)
  V_USER(219) = V(201)
  V_USER(220) = V(153)
  V_USER(221) = V(64)
  V_USER(222) = V(62)
  V_USER(223) = V(170)
  V_USER(224) = V(18)
  V_USER(225) = V(42)
  V_USER(226) = V(43)
  V_USER(227) = V(279)
  V_USER(228) = V(281)
  V_USER(229) = V(283)
  V_USER(230) = V(207)
  V_USER(231) = V(91)
  V_USER(232) = V(17)
  V_USER(233) = V(278)
  V_USER(234) = V(269)
  V_USER(235) = V(276)
  V_USER(238) = V(111)
  V_USER(239) = V(65)
  V_USER(240) = V(277)
  V_USER(241) = V(93)
  V_USER(242) = V(213)
  V_USER(243) = V(212)
  V_USER(244) = V(249)
  V_USER(245) = V(66)
  V_USER(246) = V(120)
  V_USER(247) = V(236)
  V_USER(248) = V(121)
  V_USER(249) = V(205)
  V_USER(250) = V(113)
  V_USER(251) = V(51)
  V_USER(252) = V(198)
  V_USER(253) = V(195)
  V_USER(254) = V(252)
  V_USER(255) = V(114)
  V_USER(256) = V(105)
  V_USER(257) = V(254)
  V_USER(258) = V(199)
  V_USER(259) = V(256)
  V_USER(260) = V(94)
  V_USER(261) = V(95)
  V_USER(262) = V(96)
  V_USER(263) = V(258)
  V_USER(264) = V(255)
  V_USER(265) = V(154)
  V_USER(266) = V(159)
  V_USER(267) = V(167)
  V_USER(268) = V(162)
  V_USER(269) = V(155)
  V_USER(270) = V(97)
  V_USER(271) = V(280)
  V_USER(272) = V(282)
  V_USER(277) = V(142)
  V_USER(278) = V(67)
  V_USER(279) = V(28)
  V_USER(280) = V(29)
  V_USER(281) = V(30)
  V_USER(282) = V(31)
  V_USER(284) = V(32)
  V_USER(285) = V(33)
  V_USER(286) = V(80)
  V_USER(287) = V(21)

END SUBROUTINE Shuffle_kpp2user

! End of Shuffle_kpp2user function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
! GetMass - compute total mass of selected atoms
!   Arguments :
!      CL        - Concentration of all species (local)
!      Mass      - value of mass balance
!
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SUBROUTINE GetMass ( CL, Mass )

! CL - Concentration of all species (local)
  REAL(kind=dp) :: CL(NSPEC)
! Mass - value of mass balance
  REAL(kind=dp) :: Mass(1)


END SUBROUTINE GetMass

! End of GetMass function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

! Get_OHreactivity - returns the OH reactivity
! The OH reactivity is defined as the inverse of its lifetime.
! This routine was auto-generated using script OHreact_parser.py.
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SUBROUTINE Get_OHreactivity ( CC, RR, OHreact )

! CC - Concentrations of species (local)
  REAL(kind=dp) :: CC(NSPEC)
! RR - reaction rates (local)
  REAL(kind=dp) :: RR(NREACT)
! OHreact - OH reactivity [s-1]
  REAL(kind=dp) :: OHreact

  OHreact = RR(2)*CC(276) + 2*RR(6) + 2*RR(7) + RR(8)*CC(275) + RR(9)*CC(191) &
          + RR(12)*CC(261) + RR(13)*CC(187) + RR(19)*CC(265) + RR(20)*CC(136) + RR(21)*CC(136) &
          + RR(22)*CC(193) + RR(23)*CC(193) + RR(24)*CC(264) + RR(25)*CC(281) + RR(26)*CC(235) &
          + RR(27)*CC(279) + RR(28)*CC(175) + RR(31)*CC(106) + RR(34)*CC(283) + RR(37)*CC(208) &
          + RR(38)*CC(215) + RR(41)*CC(262) + RR(46)*CC(158) + RR(50)*CC(123) + RR(51)*CC(123) &
          + RR(55)*CC(115) + RR(65)*CC(199) + RR(66)*CC(209) + RR(67)*CC(258) + RR(72)*CC(219) &
          + RR(81)*CC(222) + RR(91)*CC(132) + RR(92)*CC(155) + RR(102)*CC(252) + RR(104)*CC(233) &
          + RR(105)*CC(233) + RR(107)*CC(218) + RR(108)*CC(231) + RR(111)*CC(247) + RR(112)*CC(247) &
          + RR(119)*CC(114) + RR(120)*CC(110) + RR(121)*CC(95) + RR(122)*CC(96) + RR(123)*CC(94) &
          + RR(124)*CC(97) + RR(125)*CC(113) + RR(126)*CC(23) + RR(127)*CC(70) + RR(152)*CC(92) &
          + RR(153)*CC(92) + RR(155)*CC(142) + RR(159)*CC(284) + RR(164)*CC(125) + RR(167)*CC(271) &
          + RR(176)*CC(77) + RR(177)*CC(72) + RR(178)*CC(103) + RR(190)*CC(288) + RR(191)*CC(278) &
          + RR(196)*CC(65) + RR(231)*CC(194) + RR(233)*CC(286) + RR(234)*CC(286) + RR(235)*CC(111) &
          + RR(236)*CC(79) + RR(237)*CC(270) + RR(238)*CC(267) + RR(239)*CC(232) + RR(240)*CC(263) &
          + RR(241)*CC(102) + RR(242)*CC(75) + RR(243)*CC(78) + RR(244)*CC(44) + RR(245)*CC(85) &
          + RR(246)*CC(83) + RR(247)*CC(84) + RR(248)*CC(82) + RR(314)*CC(141) + RR(315)*CC(69) &
          + RR(316)*CC(223) + RR(323)*CC(47) + RR(324)*CC(206) + RR(325)*CC(195) + RR(339)*CC(151) &
          + RR(340)*CC(152) + RR(350)*CC(169) + RR(358)*CC(121) + RR(372)*CC(176) + RR(373)*CC(197) &
          + RR(379)*CC(133) + RR(380)*CC(90) + RR(381)*CC(89) + RR(382)*CC(88) + RR(383)*CC(91) &
          + RR(385)*CC(220) + RR(386)*CC(220) + RR(387)*CC(220) + RR(388)*CC(220) + RR(415)*CC(188) &
          + RR(416)*CC(184) + RR(417)*CC(126) + RR(418)*CC(127) + RR(419)*CC(190) + RR(420)*CC(171) &
          + RR(421)*CC(109) + RR(422)*CC(154) + RR(423)*CC(154) + RR(424)*CC(159) + RR(425)*CC(159) &
          + RR(426)*CC(154) + RR(427)*CC(159) + RR(428)*CC(167) + RR(429)*CC(162) + RR(442)*CC(116) &
          + RR(443)*CC(129) + RR(444)*CC(129) + RR(445)*CC(130) + RR(446)*CC(130) + RR(465)*CC(137) &
          + RR(466)*CC(137) + RR(467)*CC(138) + RR(468)*CC(138) + RR(469)*CC(216) + RR(470)*CC(216) &
          + RR(471)*CC(211) + RR(472)*CC(211) + RR(473)*CC(216) + RR(474)*CC(211) + RR(512)*CC(179) &
          + RR(513)*CC(148) + RR(514)*CC(179) + RR(515)*CC(148) + RR(516)*CC(148) + RR(517)*CC(179) &
          + RR(518)*CC(148) + RR(519)*CC(148) + RR(528)*CC(237) + RR(529)*CC(237) + RR(532)*CC(240) &
          + RR(535)*CC(248) + RR(537)*CC(245) + RR(538)*CC(245) + RR(541)*CC(238) + RR(542)*CC(227) &
          + RR(543)*CC(226) + RR(544)*CC(196) + RR(545)*CC(172) + RR(552)*CC(160) + RR(553)*CC(153) &
          + RR(554)*CC(117) + RR(555)*CC(183) + RR(556)*CC(166) + RR(557)*CC(131) + RR(563)*CC(135) &
          + RR(575)*CC(150) + RR(576)*CC(87) + RR(577)*CC(203) + RR(578)*CC(128) + RR(579)*CC(139) &
          + RR(580)*CC(161) + RR(581)*CC(210) + RR(582)*CC(239) + RR(584)*CC(105) + RR(585)*CC(86) &
          + RR(587)*CC(168) + RR(588)*CC(168) + RR(589)*CC(18) + RR(593)*CC(76) + RR(594)*CC(59) &
          + RR(601)*CC(68) + RR(602)*CC(119) + RR(603)*CC(119) + RR(604)*CC(63) + RR(605)*CC(80) &
          + RR(606)*CC(81) + RR(612)*CC(120) + RR(614)*CC(112) + RR(616)*CC(140) + RR(619)*CC(101) &
          + RR(624)*CC(71) + RR(626)*CC(98) + RR(631)*CC(107) + RR(634)*CC(207) + RR(638)*CC(156) &
          + RR(641)*CC(146) + RR(660)*CC(280) + RR(661)*CC(282)

END SUBROUTINE Get_OHreactivity
! End of Get_OHreactivity subroutine
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

END MODULE gckpp_Util
