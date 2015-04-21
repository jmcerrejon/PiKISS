##PiKISS for Raspberry Pi & ODROID-C1: A bunch of scripts with menu to make your life easier.

![PiKISS Logo](http://misapuntesde.com/images/pikiss_400px_nobg.png)

Estimated hours of work so far | Horas estimadas de trabajo hasta el momento:

* **422 hours**

##ENGLISH

###[ Screenshots ]

![piKiss_01](http://misapuntesde.com/images/piKiss_01.png)

![piKiss_02](http://misapuntesde.com/images/piKiss_02.png)

![piKiss_03](http://misapuntesde.com/images/piKiss_03.png)

![piKiss_04](http://misapuntesde.com/images/piKiss_04.png)

![piKiss_05](http://misapuntesde.com/images/piKiss_05.png)

###[ ChangeLog (dd/mm/yy)]

####(21/04/15)

· Added others > ramlog

· Uddated tweaks > others.sh (Install package fuck)

####(18/04/15)

· Added Emus > Picodrive & Caprice for Raspberry Pi 2 (Amstrad emulator)

####(17/04/15)

· Updated SDL2, Spectrum emulator

####(05/04/15)

· Added Others > NetTools - MITM Pentesting Opensource Toolkit

####(21/03/15)

· Updated Emulators > Mame

####(19/03/15)

· Updated Games > Return to Castle Wolfenstein

####(17/03/15)

· Added Games > Descent 1 & 2 (Shareware)

· Update Emus > PiSNES

####(16/03/15)

· ODROID: Games > Quake 2

· RPi: Updated Games > Quake 2

· Updated Tweaks > Others

####(14/03/15)

· Enhaced Games > Crispy-Doom

· ODROID: Games > Crispy-Doom

####(12/03/15)

· Added Server > Install vsftpd (FTP) Server

####(11/03/15)

· ODROID: Added Tweaks > others script

· Added Tweaks > removepkg script

· Update Info > check lastmod image

####(09/03/15)

· ODROID: Added Tweaks > autologin script

####(08/03/15)

· piKiss.sh refactorized

####(11/01/15)

· Updated ownCloud to 7.0.4

####(11/01/15)

· Added Info > Lynis (security auditing tool)

...

To see the full changes, read the file CHANGELOG

###[ Introducing PiKISS ]

Install an application on Linux is not complex. Sometimes just type *sudo apt-get install* and get the application installed with all its dependencies. But... What if we need to install more than one such as a web server?, Is it not in the official repositories?, What if you want to get rid off input commands?. Please, an easy way to set my WIFI network!.

Don't despair. **PiKISS** has come to help you...

- - -
**PiKISS** *(Pi Keeping It Simple, Stupid!)* are **shell Scripts (Bash) for *Raspberry Pi* 1 & 2 (*Raspbian* and derivates) and for *ODROID-C1* (*Ubuntu*)** soon, which has a menu that will allow you to install some applications or configure files automatically as easy as possible.

The idea is offer facilities to manage your operating system, selecting an option in a menu and answer [Yes/No]. If you need check dependencies, install an app, modify a script at boot, add a line to a file or download other, **PiKISS** will do it for you.

I include not only the ability to install, but also compile programs. Do you have problems when compiling your favorite emulator?, Have you forgotten to modify a line in the source code and now you have to recompile again for 4 hours?. Laugh your now all this with **PiKISS**.

What some users have said about **PiKISS**:

* *"It could have happened to me!"*

* *"What a silly! (I'll install it when I go home)"*

* *"Now I don't need to fight with the terminal? Shut up and take my money!."* - Easy, it's free.

**NOTE:** 100% Free of viruses and Trojans. Not available in stores. The author of **PiKISS** is not responsible if you get bored with your *Raspberry Pi* because everything is too easy. Online until I wish or *Internet* is destroyed.

####[ Installation ]

Just type:

<pre>
git clone https://github.com/jmcerrejon/PiKISS.git && cd PiKISS
./piKiss.sh
</pre>

####[ Update ]

 If you want the latest version, just enter into the directory with cd PiKISS and type:

<pre>
git pull
</pre>

NOTE: If you use another Debian based distribution, maybe you need to execute the next command: *git config --global http.sslVerify false*

####[ HELP ME! ]

**PiKISS** grow up according to users requests (ulysess@gmail.com) or  I'll append scripts that I consider necessary, but I call **to the community** to share, improve and help to add new scripts to the existing one. If the project grow, **is up to you**.

José Cerrejón [(@ulysess10)](http://twitter.com/ulysess10)

Mail: <ulysess@gmail.com>

Blog: [http://misapuntesde.com](http://misapuntesde.com)

####[ DONATE ]

This project has involved many hours thinking, searching, refactoring and testing code. I accept donations due the effort to make new scripts. Donations are not required or expected. Any amount that you feel is appropriate would be appreciated. Simply click on the Donate button at the end of this document. Thank you! :)

##ESPAÑOL

##PiKISS para Raspberry Pi y ODROID-C1: Un puñado de scripts con menú para hacerte la vida más fácil.

####[ Presentando PiKISS ]

Instalar una aplicación en Linux no es complejo. A veces basta con un *sudo apt-get install* y tendrás la aplicación con todas sus dependencias. Pero, ¿Y si tenemos que instalar más de una como por ejemplo en un servidor web?, ¿Y si no está en los repositorios oficiales?, ¿Y si no quieres teclear? ¡Por favor, una manera fácil de instalar mi pen WIFI!.

No desesperéis. Ha llegado PiKISS…

- - -
**PiKISS** *(Pi Keeping It Simple, Stupid!, "Pi manteniéndolo sencillo, ¡Estúpido!")* son unos **Shell Scripts para *Raspberry Pi* 1 y 2 (*Raspbian* y derivados), además de *ODROID-C1* (Ubuntu)** que cuenta con un menú que te va a permitir instalar algunas aplicaciones o configurar ficheros de forma automática de la manera más fácil posible. **Su misión: Simplificar la instalación de software en *Raspberry Pi* o en *ODROID-C1* y mantenerla.**

La idea es ofrecer facilidades para manejar tu distribución y que las instalaciones sean tan sencillas como seleccionar una opción en un menú y contestar [Si/No]. Si alguna conlleva algo más que instalar, por ejemplo modificar un script en el arranque, añadir una línea a un fichero, descargar otros ficheros, comprobar dependencias, **PiKISS** lo hará por ti.

Incluyo la posibilidad no solo de instalar, sino también de compilar programas. ¿Problemas a la hora de compilar tu emulador favorito?, ¿Se te ha olvidado modificar una línea en el código fuente de su autor y tienes que volver a recompilar durante 4 horas?. Ríete tu ahora de todo esto con **PiKISS**.

Lo que algunos usuarios han dicho de **PiKISS**:

*"¡Se me podría haber ocurrido a mí!"*

*"Menuda tontería (voy a instalarlo en cuanto llegue a casa)"*

*"¿Ya no tengo que pelearme con la terminal?. Cállate y coge mi dinero!"* - Tranquilos, es gratis.

**NOTA:** 100% Libre de virus y troyanos. No disponible en tiendas. El autor de *PiKISS* no se hace responsable si te aburres con tu RasPi porque todo es demasiado fácil. Online hasta que me plazca o se destruya *Internet*.

####[ Instalación ]

Escribe en la terminal lo siguiente:

<pre>
git clone https://github.com/jmcerrejon/PiKISS.git && cd PiKISS
./piKiss.sh
</pre>

####[ Actualizar ]

Si ya la tienes instalada y quieres actualizarla con los últimos cambios, teclea en el directorio de *PiKISS*:

<pre>
git pull
</pre>

NOTA: Si usas otra distribución que no sea *Raspbian* en la Raspberry Pi, tal vez tengas que ejecutar esta sencencia: *git config --global http.sslVerify false*

####[ ¡AYÚDAME! ]

**PiKISS** crecerá de acuerdo a las peticiones de los usuarios  o añadiré los scripts que considere oportunos, pero hago un llamamiento a **toda la comunidad** para compartir, mejorar o agregar nuevos scripts a los ya existentes. Que este proyecto crezca **depende de tí**.

¡Gracias!

José Cerrejón [(@ulysess10)](http://twitter.com/ulysess10)

Mail: <ulysess@gmail.com>

Blog: [http://misapuntesde.com](http://misapuntesde.com)

####[ DONACIONES ]

Este proyecto ha supuesto muchas horas de pensar, buscar, refactorizar y testear código. Acepto donaciones por el esfuerzo que supone mantener y hacer nuevos scripts. Las donaciones no se requieren ni las espero. Cualquier cantidad que sientas que es apropiada sería de agradecer. Simplemente haz click en el botón "Donate" al final del documento. ¡Gracias! :)

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ulysess%40gmail%2ecom&lc=GB&item_name=PiKISS%20proyect&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"><img src="https://www.paypalobjects.com/en_GB/i/btn/btn_donate_SM.gif" /></a>
