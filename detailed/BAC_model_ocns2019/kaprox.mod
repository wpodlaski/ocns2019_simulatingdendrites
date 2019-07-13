TITLE K-A channel from Klee Ficker and Heinemann
: modified to account for Dax A Current ----------
: M.Migliore Jun 1997

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)

}

INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

PARAMETER {
        dt (ms)
	v (mV)
        ek (mV)              : must be explicitely def. in hoc
	celsius = 24	(degC)
	gkabar=.008 (mho/cm2)
        vhalfn=11   (mV)
        vhalfl=-56   (mV)
        a0l=0.05      (/ms)
        a0n=0.05    (/ms)
        zetan=-1.5    (1)
        zetal=3    (1)
        gmn=0.55   (1)
        gml=1   (1)
	lmin=2  (mS)
	nmin=0.1  (mS)
	pw=-1    (1)
	tq=-40
	qq=5
	q10=5
	qtl=1
}


NEURON {
	SUFFIX kap
	USEION k READ ek WRITE ik
        RANGE gkabar,gka
        GLOBAL ninf,linf,taul,taun,lmin
}

STATE {
	n
        l
}

ASSIGNED {
	ik (mA/cm2)
        ninf
        linf      
        taul
        taun
        gka
}

BREAKPOINT {
	SOLVE states
	gka = gkabar*n*l
	ik = gka*(v-ek)

}


FUNCTION alpn(v(mV)) {
LOCAL zeta
  zeta=zetan+pw/(1+exp((v-tq)/qq))
  alpn = exp(1.e-3*zeta*(v-vhalfn)*9.648e4/(8.315*(273.16+celsius))) 
}

FUNCTION betn(v(mV)) {
LOCAL zeta
  zeta=zetan+pw/(1+exp((v-tq)/qq))
  betn = exp(1.e-3*zeta*gmn*(v-vhalfn)*9.648e4/(8.315*(273.16+celsius))) 
}

FUNCTION alpl(v(mV)) {
  alpl = exp(1.e-3*zetal*(v-vhalfl)*9.648e4/(8.315*(273.16+celsius))) 
}

FUNCTION betl(v(mV)) {
  betl = exp(1.e-3*zetal*gml*(v-vhalfl)*9.648e4/(8.315*(273.16+celsius))) 
}
LOCAL facn,facl

:if state_borgka is called from hoc, garbage or segmentation violation will
:result because range variables won't have correct pointer.  This is because
: only BREAKPOINT sets up the correct pointers to range variables.
PROCEDURE states() {     : exact when v held constant; integrates over dt step
        rates(v)
        n = n + facn*(ninf - n)
        l = l + facl*(linf - l)
        VERBATIM
        return 0;
        ENDVERBATIM
}

PROCEDURE rates(v (mV)) { :callable from hoc
        LOCAL a,qt
        qt=q10^((celsius-24)/10)
        a = alpn(v)
        ninf = 1/(1 + a)
        taun = betn(v)/(qt*a0n*(1+a))
	if (taun<nmin) {taun=nmin}
        facn = (1 - exp(-dt/taun))
        a = alpl(v)
        linf = 1/(1+ a)
	taul = 0.26*(v+50)/qtl
	if (taul<lmin/qtl) {taul=lmin/qtl}
        facl = (1 - exp(-dt/taul))
}
