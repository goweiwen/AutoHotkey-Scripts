﻿; Hide Tray Icon
NoTrayIcon := True

if (NoTrayIcon)
	Menu, Tray, NoIcon

CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
SetWinDelay, -1

; Symbols and Accented/Foreign/Special Characters (for accents, type ` followed by accent and letter)
{
	;Math
	{

		;Fractions
		{
			:*?:``1/2::½

			:*?:``1/3::⅓
			:*?:``2/3::⅔

			:*?:``1/4::¼¼
			:*?:``3/4::¾

			:*?:``1/5::⅕
			:*?:``2/5::⅖
			:*?:``3/5::⅗
			:*?:``4/5::⅘

			:*?:``1/6::⅙
			:*?:``5/6::⅚

			:*?:``1/8::⅛
			:*?:``3/8::⅜
			:*?:``5/8::⅝
			:*?:``7/8::⅞
		
		}
				
		;Subscripts and superscripts
		{ 
			;Super
			{
				:*?:``^1::¹
				:*?:``^2::²
				:*?:``^3::³
				:*?:``^4::⁴
				:*?:``^5::⁵
				:*?:``^6::⁶
				:*?:``^7::⁷
				:*?:``^8::⁸
				:*?:``^9::⁹
				:*?:``^0::⁰
				:*?:``^+::⁺
			}

			;Sub
			{
				:*?:``_0::₀
				:*?:``_1::₁
				:*?:``_2::₂
				:*?:``_3::₃
				:*?:``_4::₄
				:*?:``_5::₅
				:*?:``_6::₆
				:*?:``_7::₇
				:*?:``_8::₈
				:*?:``_9::₉
				:*?:``_+::₊
				:*?:``_-::₋
				:*?:``_=::₌
				:*?:``_(::₍
				:*?:``_)::₎
			}
		}

		;Misc. Math
		{ 
			:*?:``^o::°
			:*?:``div::÷
			:*?:``mult::×
			:*?:``+-::±
			:*?:``!=::≠
			:*?:``<=::≤	
			:*?:``>=::≥	
			:*?:``~=::≈	
			:*?:``sqrt::√
			:*?:``inf::∞
		}
		
	}
	
	;Currency
	{ 
		:*?:``$c::¢
		:*?:``$P::£
		:*?:``$Y::¥
		:*?:``$E::€

	}

	;Accented letters
	{
		;Tilde and Cedilla
		{
			:*?:``~a::ã
			:*?:``~c::ç
			:*?:``~n::ñ
			:*?:``~o::õ
		}

		;Acute accent
		{	
			:*?:``'a::á
			:*?:``'e::é
			:*?:``'i::í
			:*?:``'o::ó
			:*?:``'u::ú
		}

		;Grave accent
		{
			:*?:````a::à
			:*?:````e::è
			:*?:````i::ì
			:*?:````o::ò
			:*?:````u::ù
		}
		
		;Caret/Circumflex
		{		
			:*?:``^a::â
			:*?:``^e::ê
			:*?:``^i::î
			:*?:``^o::ô
			:*?:``^u::û
		}
		
		;Caron
		{		
			:*?:``va::ǎ
			:*?:``ve::ě
			:*?:``vi::ǐ
			:*?:``vo::ǒ
			:*?:``vu::ǔ
		}

		;Macron
		{
			:*?:``|a::ā
			:*?:``|e::ē
			:*?:``|i::ī
			:*?:``|o::ō
			:*?:``|u::ū		
		}

		;Umulaut/Diaeresis
		{		
			:*?:``:a::ä
			:*?:``:e::ë
			:*?:``:i::ï
			:*?:``:o::ö
			:*?:``:u::ü
			:*?:``:y::ÿ
			:*?:``"a::ä
			:*?:``"e::ë
			:*?:``"i::ï
			:*?:``"o::ö
			:*?:``"u::ü
			:*?:``"y::ÿ	
		}
			
	}
	
	;Greek letters
	{
		; Capital
		{
			:?C:``ALPHA::Α
			:?C:``BETA::Β
			:?C:``GAMMA::Γ
			:?C:``DELTA::Δ
			:?C:``EPSILON::Ε
			:?C:``ZETA::Ζ
			:?C:``ETA::Η
			:?C:``THETA::Θ
			:?C:``IOTA::Ι
			:?C:``KAPPA::Κ
			:?C:``LAMBDA::Λ
			:?C:``MU::Μ
			:?C:``NU::Ν
			:?C:``XI::Ξ
			:?C:``OMICRON::Ο
			:?C:``PI::Π
			:?C:``RHO::Ρ
			:?C:``SIGMA::Σ
			:?C:``TAU::Τ
			:?C:``UPSILON::Υ
			:?C:``PHI::Φ
			:?C:``CHI::Χ
			:?C:``PSI::Ψ
			:?C:``OMEGA::Ω
		}
		
		; Lowercase
		{
			:?C:``alpha::α
			:?C:``beta::β
			:?C:``gamma::γ
			:?C:``delta::δ
			:?C:``epsilon::ε
			:?C:``zeta::ζ
			:?C:``eta::η
			:?C:``theta::θ
			:?C:``iota::ι
			:?C:``kappa::κ
			:?C:``lambda::λ
			:?C:``mu::μ
			:?C:``nu::ν
			:?C:``xi::ξ
			:?C:``omicron::ο
			:?C:``pi::π
			:?C:``rho::ρ
			:?C:``sigma::σ
			:?C:``finalsigma::ς
			:?C:``terminalsigma::ς
			:?C:``tau::τ
			:?C:``upsilon::υ
			:?C:``phi::φ
			:?C:``chi::χ
			:?C:``psi::ψ
			:?C:``omega::ω
		}		
	}
	
	;Misc. letter-based and punctuation special characters
	{
		:*?:``ae::æ
		:*?:``oe::œ
		:*?:``thorn::Þ
		:*?:``RR::Я
		:*?:``NN::И
		:*?:``BB::ß
		:*?:``longs::ſ
		:*?:``SS::§
		:*?:``--::—
		:*?:``^_::‾
		:*?:``(c)::©
		:*?:``(r)::®
		:*?:``tm::™
		:*?:``para::¶
		:*?:``<<::«
		:*?:``>>::»
		:*?:``dot::·
		!+1::¡
		!+/::¿
		:*?:``...::…
		:*?:``dakuten::ﾞ
		:*?:``handakuten::ﾟ
	}
	
	;Emoticons, dingbats, etc.
	{	
		:*?:``->::→
		:*?:``<-::←
		:*?:``/::／
		:*?:``\::＼

		::``denko::(´・ω・`)
		::``bear::ˁ˚ᴥ˚ˀ
		::``kyubey::／人 ◕‿‿◕ 人＼
		::``help::٩(͡๏̯͡๏)۶
		::``lenny::( ͡° ͜ʖ ͡°)
		::``fliptable::(╯°□°）╯︵ ┻━┻
		::``umadbro::¯\_(ツ)_`/¯
		::``angry::ლ(ಠ益ಠლ)
		::``disapproval::ಠ_ಠ
		::``cry::ಥ_ಥ
		::``eyeroll::◔̯◔
		::``smug::(‾⌣‾)
		::``censor::████

		:*?:```:`)::☺
		:*?:```:`(::☹
		:*?:``black`:`)::☻

		::``male::♂
		::``female::♀
		:*?:``<3::♥

		::``spade::♠
		::``club::♣
		::``diamond::♦
		::``heart::♥

		::``circle::◯
		::``blackcircle::⬤
		::``square::◻
		::``blacksquare::◼

		:*?:``note::♩
		:*?:``quarternote::♪
		:*?:``eighthnote::♫
		:*?:``sixteenthnote::♬
		:*?:``notes::♩♪♫♬
		:*?:``sharp::♯
		:*?:``#::♯
		:*?:``flat::♭

		::``tick::☑
		::``cross::☒
		::``box::☐

		::``option::⌘

		:*?:``?!::‽
		:*?:``!?::‽ 

	}
	
	; Emoji
	{
		:*?:```:D::😄
		:*?:``XD::😆
		:*?:```:'`(::😭
		::``penguin::🐧
		::``cat::😺
		::``dog::🐶
		::``mouse::🐭
		::``panda::🐼
		::``snake::🐍
		::``tortoise::🐢
		::``octopus::🐙
		::``bird::🐥
		::``sheep::🐑
		::``fish::🐟
		::``elephant::🐘
		::``camel::🐫
		::``paw::🐾
		::``poop::💩 
		::``vein::💢
		::``mail::✉
		::``ball::⚽
		::``snow::❆
		::``snowman::☃
		::``scale::⚖
		::``swords::⚔
		::``atom::⚛
		::``umbrella::☂
		::``info::⚠
		::``toilets::🚻
		::``toiletmale::🚹
		::``toiletfemale::🚺
		::``apple::🍎
		::``fruits::🍎 🍏 🍊 🍋 🍒 🍇 🍉 🍓 🍑 🍈 🍌 🍐 🍍 🍠 🍆 🍅 🌽 
		::``food::☕ 🍵 🍶 🍼 🍺 🍻 🍸 🍹 🍷 🍴 🍕 🍔 🍟 🍗 🍖 🍝 🍛 🍤 🍱 🍣 🍥 🍙 🍘 🍚 🍜 🍲 🍢 🍡 🍳 🍞 🍩 🍮 🍦 🍨 🍧 🎂 🍰 🍪 🍫 🍬 🍭 🍯 
		::``monkeys::🙈 🙉 🙊
		::```[up`]::🆙
		::```[ok`]::🆗
		::```[new`]::🆕
		::```[cool`]::🆒
		::```[free`]::🆓
		::```[ng`]::🆖
		::```[koko`]::🈁
		::```[sa`]::🈂
		::```[yes`]::🈶
		::```[no`]::🈚
		::```[can`]::🉑
		::```[get`]::🉐
		::```[cl`]::🆑
		::```[sos`]::🆘
		::```[id`]::🆔
		::```[vs`]::🆚
		::```[moon`]::🈷
		::```[empty`]::🈳
		::```[full`]::🈵
		::``error::⛔
		:*?:``|>::▶
		:*?:``<|::◀
	}
}