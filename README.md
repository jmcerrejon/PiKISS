# PiKISS for Raspberry Pi: A bunch of scripts with menu to make your life easier.

![PiKISS Logo](logo_pikiss_header.png)

<p align="center">
	<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ulysess%40gmail%2ecom&lc=GB&item_name=PiKISS&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"><img src="https://www.paypalobjects.com/en_GB/i/btn/btn_donate_SM.gif" /></a>
	<a href='https://ko-fi.com/cerrejon' target='_blank'><img height="20" src="https://az743702.vo.msecnd.net/cdn/kofi2.png?v=0" alt='Buy Me a Coffee at ko-fi.com' /></a>
	<a href="https://github.com/jmcerrejon/neighborhood-games/blob/master/LICENSE"><img src="https://img.shields.io/github/license/jmcerrejon/neighborhood-games" alt="npm version"></a>
	<a href="https://twitter.com/ulysess10"><img src="https://img.shields.io/twitter/follow/ulysess10?style=social" alt="Follow me on Twitter!"></a>
	<a href="https://github.com/jmcerrejon/PiKISS/search?l=shell"><img src="https://img.shields.io/github/languages/top/jmcerrejon/pikiss" alt="language top"></a>
	<a href="https://commerce.coinbase.com/checkout/71737f60-2440-488e-b413-f41e706f024b"><img height="20" src="https://estafaonline.com/wp-content/uploads/2019/02/Coinbase-logo.png" alt="Coinbase"></a>
</p>

## ⏰ Estimated hours of work so far

* **734 hours**

## 💰 Total amount donated by users

* $275,06.

* I want to thank my patrons *James Carroll, David J Leto, Mike A. Torevell and Rodney Hester* for trusting me ❤️

* Others users who helped me with donations are: danoga.

## 📣 Stay tuned! 

* 📬⠀Mail: <ulysess@gmail.com>

* 📖⠀Blog (English & Spanish): [misapuntesde.com](https://misapuntesde.com/)

* 💰⠀Patreon: [patreon.com/cerrejon](https://www.patreon.com/cerrejon?fan_landing=true)

* 🐦⠀Twitter: [@ulysess10](https://twitter.com/ulysess10)

* 👾⠀Discord for suggestions & support [thanks to Pi Labs](https://discord.gg/Y7WFeC5) 

* 👨🏻‍💻⠀LinkedIn: [es.linkedin.com/in/jmcerrejon](https://es.linkedin.com/in/jmcerrejon/)

* 📣⠀Mewe (Spanish): [mewe.com](https://mewe.com/group/5c6bbed8f0e71669f228c457)

## 🤝 Contributors

* [huelvayork](https://github.com/huelvayork)

* Logo: grayduck

* **This project is not accepting money or any benefits**.

## 🎥 Check what **PiKISS** can do for you on my Youtube's channel:

* [youtube.com > PIKISS](https://www.youtube.com/playlist?list=PLXhElW3ALmWh8p0mn1ZECawkKyF8QzNNP)

# 🚨🚨 Read the new info about Data Files below 🚨🚨

## ENGLISH

### [ Screenshots ]

![piKiss_01](screenshots/pikiss_twisterOS_01.png)

![piKiss_02](screenshots/pikiss_twisterOS_02.png)

![piKiss_03](screenshots/pikiss_twisterOS_03.png)

![piKiss_04](screenshots/pikiss_twisterOS_04.png)

### [ ChangeLog (dd/mm/yy)]

### (03/11/20)

· 👌 IMPROVE: Emulators > mGBA Game Boy Advance Emulator.

### (24/10/20)

· 👌 IMPROVE: GAMES > MagicAirCopy® now supports local files/directories.

### (19/10/20)

· 🐛 FIX: GAMES > Diablo 1.

### (17/10/20)

· 📦 ADD: Games > Return to Castle Wolfenstein.

### (14/10/20)

· 👌 IMPROVE: Configure > Compile/update Vulkan Mesa driver.

### (12/10/20)

· 👌 IMPROVE: Devs > Change OSSCode with native VSCode 32 or 64 bits.

### (07/10/20)

· 🐛 FIX: Games > Openmw.

### (06/10/20)

· 🐛 FIX: Internet > Zoom on Twister OS.

· 🐛 FIX: Games > Openbor.

### (03/10/20)

· 📦 ADD: Internet > Zoom using Box86.

· 📦 ADD: Emulation > Box86 for Raspberrry Pi 2-4.

### (02/10/20)

· 🐛 FIX: Games > Half Life (add *Steam* data files support).

### (01/10/20)

· 👌 REFACTOR: Games > Diablo 1, Half Life (disabled fps caps & fps max:150 fps), Alien Vs Predator.

### (29/09/20)

· 👌 IMPROVE: Games > OpenBor 3.0 (Streets of Rage 2X included!).

· 👌 IMPROVE: Others > SDL2 (Enable Vulkan support if you compile it yourself).

### (27/09/20)

· 📦 ADD: Games > Quake.

### (20/09/20)

· 📦 ADD: Games > Half Life.

### (11/09/20)

· 📦 ADD: Games > Blake Stone.

### (07/09/20)

· 📦 ADD: Games > Quake 3 Arena (with Vulkan support, High textures and some tweaks).

### (01/09/20)

· 📦 ADD: Games > The Elder Scroll: Morrowind (*OpenMW*).

· 📦 ADD: Others > Compile GL4ES.

...

To see the full list of changes, read the [CHANGELOG](./CHANGELOG)

## [ Introducing PiKISS ]

Install an application on Linux is not a complex task. Sometimes just type *sudo apt install* and get the application installed with all its dependencies. But... What if we need to install more than one app such as a web server or it requires many steps to complete the install process?, Is it not in the official repositories?, What if you want to get rid of input commands?. Please, an easy way to set up my WIFI network!.

Don't despair. **PiKISS** has come to help you...

- - -
**PiKISS** *(Pi Keeping It Simple, Stupid!)* are *scripts (Bash)* for *Raspberry Pi* boards (*Raspberry OS* mainly, [TwisterOS](https://raspbian-x.com/) and *Debian* derivates, all of them in *32 bits versions*), which has a menu that will allow you to install some applications or configure files automatically as easy as possible.

The idea is to offer facilities to manage your operating system, selecting an option in a menu and answer [Yes/No]. If you need to check dependencies, install an app, modify a script at boot, add a line to a file or download other, **PiKISS** will do it for you.

I include not only the ability to install, but also compile programs. Do you have problems when compiling your favorite emulator?, Have you forgotten to modify a line in the source code and now you have to recompile again for 4 hours?. Laugh your now all this with **PiKISS**.

What some users have said about **PiKISS**:

* *"It could have happened to me!"*

* *"That's silly! (I'm going to install it as soon as I get home)"*

* *"I don't need to fight with the terminal anymore? Shut up and take my money!."* - Easy, it's free.

**NOTE:** 100% Free of viruses and Trojans. Not available in stores. The author of **PiKISS** is not responsible if you get bored with your *Raspberry Pi* because everything is too easy. Online until I wish or *Internet* is destroyed.

## [ Installation ]

Just type:

```sh-session
$ curl -sSL https://git.io/JfAPE | bash
```

## [ Data Files 🚨 ]

Honestly, I just want everything to work without having to fight with the command line. The project has grown a lot, and the games I own and had hosted on the internet, can't be there because of *Copyright*. I don't understand how a game that is older than 15 years old in some cases, has these so restrictive laws in some countries. Someone should do something about it.

**My solution to keep this project working is the following**: If you have copies saved for your use, just copy those links/paths in a file at ``` res/magic-air-copy-pikiss.txt ```. You have an example of this file with instrucctions at [./res/magic-air-copy-pikiss.example](./res/magic-air-copy-pikiss.example). *PiKISS* will read the links/files/directories in that file and install it for you when is required. Compatible and tested hosters: *dropbox.com, archive.org, anonfiles.com, pcloud.com*.

You can share this file *magic-air-copy-pikiss.txt* with your brother/sister if you paid half price for the game and if the laws of your country allow it.

## [ Update ]

*PiKISS* check if new scripts are available on remote and update them automatically, but If you want to get the latest version manually, just enter into the directory with cd PiKISS and type:

```sh-session
$ git pull
```

**NOTE:** If you use another distribution other than *Raspberry OS/TwisterOS*, maybe you need to execute the next command: *git config --global http.sslVerify false*

### [ HELP ME! ]

**PiKISS** grow up according to users requests or I'll append scripts that I consider necessary, but I call **to the community** to share, improve and help to add new scripts to the existing one. If the project grow, **is up to you**.

## ESPAÑOL

## PiKISS para Raspberry Pi: Un puñado de scripts con menú para hacerte la vida más fácil.

### [ Presentando PiKISS ]

Instalar una aplicación en Linux no es complejo. A veces basta con un *sudo apt install* y tendrás la aplicación con todas sus dependencias. Pero, ¿Y si tenemos que instalar más de una app como por ejemplo en un servidor web o necesita varios pasos para completar el proceso de instalación?, ¿Y si no está en los repositorios oficiales?, ¿Y si no quieres teclear? ¡Por favor, una manera fácil de instalar mi red WIFI!.

No desesperéis. Ha llegado **PiKISS** para ayudarte...

- - -
**PiKISS** *(Pi Keeping It Simple, Stupid!, "Pi manteniéndolo sencillo, ¡Estúpido!")* son unos *scripts en Bash* para placas *Raspberry Pi* (*Raspberry OS*, [TwisterOS](https://raspbian-x.com/) y derivados *Debian* todas ellas en versiones de *32 bits*), que cuenta con un menú que te va a permitir instalar algunas aplicaciones o configurar ficheros de forma automática de la manera más fácil posible. **Su misión: Simplificar la instalación de software en *Raspberry Pi* o en *ODROID-C1* y mantenerla.**

La idea es ofrecer facilidades para manejar tu distribución y que las instalaciones sean tan sencillas como seleccionar una opción en un menú y contestar [Si/No]. Si alguna conlleva algo más que instalar, por ejemplo modificar un script en el arranque, añadir una línea a un fichero, descargar otros ficheros, comprobar dependencias, **PiKISS** lo hará por ti.

Incluyo la posibilidad no solo de instalar, sino también de compilar programas. ¿Problemas a la hora de compilar tu emulador favorito?, ¿Se te ha olvidado modificar una línea en el código fuente de su autor y tienes que volver a recompilar durante 4 horas?. Ríete tú ahora de todo esto con **PiKISS**.

Lo que algunos usuarios han dicho de **PiKISS**:

*"¡Se me podría haber ocurrido a mí!"*

*"Menuda tontería (voy a instalarlo en cuanto llegue a casa)"*

*"¿Ya no tengo que pelearme con la terminal?. Cállate y coge mi dinero!"* - Tranquilos, es gratis.

**NOTA:** 100% Libre de virus y troyanos. No disponible en tiendas. El autor de *PiKISS* no se hace responsable si te aburres con tu *Raspberry Pi* porque todo es demasiado fácil. Online hasta que me plazca o se destruya *Internet*.

### [ Instalación ]

Escribe en la terminal lo siguiente:

```sh-session
$ curl -sSL https://git.io/JfAPE | bash
```

## [ Ficheros de datos 🚨 ]

Sinceramente, lo único que quiero es que todo funcione sin tener que pelearme con la línea de comandos. El proyecto ha crecido mucho, y los juegos que yo poseo y que tenía alojados en internet, no pueden estar allí por motivos de *Copyright*. Tampoco entiendo como un juego que tiene más de 15 años en algunos casos, tienen estas leyes tan restrictivas en algunos países. Alguien debería hacer algo al respecto.

**Mi solución para que este proyecto siga funcionando es el siguiente**: Si tienes copias guardadas para tu uso, copia dichos enlaces/rutas en el fichero ``` res/magic-air-copy-pikiss.txt ```. Tienes un ejemplo de este fichero en [./res/magic-air-copy-pikiss.example](./res/magic-air-copy-pikiss.example). *PiKISS* leerá los enlaces/rutas de ese fichero y te instalará el que necesite cuando proceda. Hosters testeados y compatible: *dropbox.com, archive.org, anonfiles.com, pcloud.com*.

Este fichero *magic-air-copy-pikiss.txt* lo puedes compartir con tu herman@ si pagásteis a medias el juego y si las leyes de tu país lo permiten.

### [ Actualizar ]

*PiKISS* comprueba si hay nuevas actualizaciones en remoto y las actualiza automaticamente, pero si quieres conseguir la última versión de forma manual, teclea en el directorio de *PiKISS*:

```sh-session
$ git pull
```

**NOTA:** Si usas otra distribución que no sea *Raspberry OS/TwisterOS* en la *Raspberry Pi*, tal vez tengas que ejecutar esta sencencia: *git config --global http.sslVerify false*

### [ ¡AYÚDAME! ]

**PiKISS** crecerá de acuerdo a las peticiones de los usuarios o añadiré los scripts que considere oportunos, pero hago un llamamiento a **toda la comunidad** para compartir, mejorar o agregar nuevos scripts a los ya existentes. Que este proyecto crezca **depende de tí**.
