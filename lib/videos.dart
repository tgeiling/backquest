library videos;


import 'package:backquest/data_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:giff_dialog/giff_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';


Map<int, Color> color = {
  50: const Color.fromRGBO(64, 154, 181, .1),
  100: const Color.fromRGBO(64, 154, 181, .2),
  200: const Color.fromRGBO(64, 154, 181, .3),
  300: const Color.fromRGBO(64, 154, 181, .4),
  400: const Color.fromRGBO(64, 154, 181, .5),
  500: const Color.fromRGBO(64, 154, 181, .6),
  600: const Color.fromRGBO(64, 154, 181, .7),
  700: const Color.fromRGBO(64, 154, 181, .8),
  800: const Color.fromRGBO(64, 154, 181, .9),
  900: const Color.fromRGBO(64, 154, 181, 1),
};

List<Map<String, dynamic>> _videoList = [
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834199066/rendition/720p/file.mp4?loc=external&signature=7ccaddbc42656a8dabed22fd305723431732333803baa30812e0ef827ee38028',
    'text': "Der Anfang deiner Rückengesundheit: Schritt für Schritt",
    'shortDescription': 'Du startest mit einer kurzen Atemübung.\n'
        'Dein Körper und Geist kommen zur Ruhe.\n'
        'Bereit für die folgenden Lockerungsübungen für Hüfte, Nacken und Brustwirbelsäule.\n\n'
        'Video 1.1: Starte in Rückenlage\n'
        '\t1. RL Krokodilatmung\n'
        '\t2. Supine Reaching\n'
        '\t3. Nacken auslockern\n'
        '\t4. Baby Rolling\n'
        '\t5. BL Ellbogenstütz hochschieben',
    'description': "Willkommen bei BackQuest, deinem persönlichen Begleiter auf dem Weg zu einem gesunden Rücken! "
        "Mache mit diesem Video den ersten Schritt und entscheide dich für eine positive Veränderung…\n\n"
        "Denke bitte daran das hier ist nur unsere erste Testversion und ist noch weit von der Vision entfernt, die wir eines Tages erreichen wollen. Dafür brauchen wir DICH!\n\n"
        "Mit deinem Feedback, deinen Erfahrungen und deinen Wünschen können wir eine einzigartige App entwickeln, um so vielen Menschen wie möglich zu helfen!\n\n"
        "Dieses Video ist der Beginn einer neuen Gewohnheit. Ich weiß, dass es nicht immer einfach ist, aber sei geduldig mit dir selbst. Jeder kleine Fortschritt ist ein Schritt in die richtige Richtung.\n\n"
        "Manchmal wenn wir einen neuen Weg in unserem Leben einschlagen wollen, fühlt es sich an, als würden wir in tiefem Schlamm laufen. Unsere Schuhe werden mit jedem Schritt schwerer und jeder Schritt kostet mehr Anstrengung.\n\n"
        "Gerade dann lohnt es sich aufzuschauen. Manchmal sieht man erst dann, dass es noch einen anderen Weg gibt.\n\n"
        "BackQuest – Der einfache Weg zur Rückengesundheit",
    'overlay': const Thumbnail('assets/thumbnails/1.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834201612/rendition/720p/file.mp4?loc=external&signature=4be3cb1a0d128710d08a3f60fd3c18c0d0df257ee53d7484f9af9732279eb124',
    'text': "Entspannter Atem – Entspannter Rücken",
    'shortDescription': "Du verbindest den Atem mit Kräftigungsübungen.\n"
        "Dein Atem bringt dir mehr Stabilität im Rumpf.\n"
        "Atme immer weiter und lasse bei der Kräftigungsübung den Bauchnabel zur Wirbelsäule gezogen.\n"
        "Danach löst du die Spannung wieder mit einigen Lockerungsübungen.\n\n"
        "Video 1.2: Starte in Rückenlage\n"
        "1.\tRL Krokodilatmung\n"
        "2.\tTucked Hollow Body Hold\n"
        "3.\tToter Käfer\n"
        "4.\tBaby Rolling\n"
        "5.\tBL Ellbogenstütz hochschieben",
    'description': "Wie du im letzten Video gemerkt hast, starten wir am Anfang oft mit einer kurzen Atemmethode…\n\n"
        "Gönn dir damit eine wohlverdiente Auszeit vom Alltagsstress und schenke dir und deinem Rücken einen Moment der Ruhe.\n\n"
        "Mit der Atmung aktivierst Du dein parasympathisches Nervensystem. Spüre, wie der Stress von dir abfällt und ein Gefühl der Ruhe sich in dir ausbreitet.\n\n"
        "Erst entspannt entfalten die folgenden Dehn- und Mobilisationsübungen ihr ganzes Potenzial.",
    'overlay': const Thumbnail('assets/thumbnails/2.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/842179506/rendition/720p/file.mp4?loc=external&signature=0f91f0270a14634eb0e75118f5cf1588c5197ed87fb401fdb55a05d786382717',
    'text': "Roll dich gesund",
    'shortDescription':
        "Zuerst bringst du mit deiner Atmung Stabilität in den Rumpf.\n"
            "Lass beim Baby Rolling deine Beine ganz locker.\n"
            "Mit etwas Übung überträgt dein Rumpf die Bewegung der Arme weiter auf den Unterkörper.\n\n"
            "Video 1.3: Starte in Rückenlage\n"
            "1.\tTucked Hollow Body Krokodilsatmung\n"
            "2.\tBaby Rolling\n"
            "3.\tBL Einzelellebogenstütz\n"
            "4.\tToter Käfer\n"
            "5.\tRL Nacken auslockern",
    'description': "Bereit für ein Abenteuer, dass deinen Rücken stärkt und dich von Schmerzen befreit? In diesem Video lernst du die faszinierende Welt des Baby Rollings kennen, einer Methode zur Prävention von Rückenschmerzen…\n\n"
        "Es basiert auf der Bewegungsentwicklung von Säuglingen und Kleinkindern, die das Rollen erlernen, um ihre motorischen Fähigkeiten zu entwickeln.\n\n"
        "Leider haben viele Erwachsene verlernt sich, ohne die Kraft ihrer Beine zu rollen. Versuche die Bewegung nur über die Bewegung deiner Arme einzuleiten und spüre, wie deine Rumpfmuskulatur die Bewegung weiter überträgt.\n\n"
        "Spüre wie Körperwahrnehmung, Koordination und Wohlbefinden sich verbessern.",
    'overlay': const Thumbnail('assets/thumbnails/3.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834206245/rendition/720p/file.mp4?loc=external&signature=5a565e80adb8ad094c3ee29099922c508aac2de8dbacac5eee55761611529ee5',
    'text':
        "Proximale Stabilität für distale Mobilität: Stärke deinen Kern für bessere Beweglichkeit",
    'shortDescription': "Deine Atmung bringt Stabilität in deine Körpermitte.\n"
        "Dadurch werden deine Extremitäten beweglicher.\n"
        "Erfahre das Prinzip der Proximalen Stabilität durch eine Wechsel von Mobilitäts- und Kräftigungsübungen.\n\n"
        "Video 1.4: Starte in Rückenlage\n"
        "1.\tRL Krokodilatmung\n"
        "2.\tKletternder Affe\n"
        "3.\tBL Ellbogenstütz hochschieben\n"
        "4.\tBaby Rolling\n"
        "5.\tBL Ellbogenstütz halbe Nackenkreise",
    'description':
        "Bereit, deinen Körper auf ein neues Level der Beweglichkeit zu bringen? In diesem Video erfährst du alles über das Prinzip der proximalen (körpernah) Stabilität für distale (körperfern) Mobilität…\n\n"
            "Dieses grundlegende Konzept der Sport- und Physiotherapie besagt, dass eine kontrollierte Rumpf- und Atemmuskulatur (proximale Stabilität) die Voraussetzung schafft, dass Muskeln und Gelenke der entfernten Körperregionen (distale Mobilität) frei und effizient arbeiten können.\n\n"
            "Stärke deinen Kern und erlebe die Freude an einem geschmeidigen und beweglichen Körper!",
    'overlay': const Thumbnail('assets/thumbnails/4.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834208309/rendition/720p/file.mp4?loc=external&signature=43647bcbdbab7cd1066b2710ae2e2587531e15dcc0b8d4dcce11ccfa06a87b5d',
    'text': "Faszienrollen ohne Rolle: Befreie deinen Rücken mit Bodenübungen",
    'shortDescription': "Du lockerst deine Faszien ganz ohne Faszienrolle.\n"
        "Deine Faszien reagieren auf Druck.\n"
        "Dafür kannst du auch ganz einfach den Boden nutzen.\n\n"
        "Video 1.5: Starte in Rückenlage\n"
        "1.\tRL Krokodilatmung\n"
        "2.\tKletternder Affe\n"
        "3.\tRückenroller\n"
        "4.\tBL Einzelellbogenstütz\n"
        "5.\tBaby Rolling",
    'description': "Bist du bereit, deinen Rücken zu befreien und dich von Verspannungen zu lösen?\n\n"
        "In diesem Video zeigen wir dir, …\n\n"
        "wie du Faszienrollen ganz ohne Rolle verwenden kannst – mit einfachen Bodenübungen für deinen Rücken.\n\n"
        "Du brauchst keine teure Ausrüstung, denn der Boden wird zu deinem besten Freund.\n\n"
        "Wir führen dich durch eine Reihe von gezielten Übungen, bei denen du deinen Körper sanft auf dem Boden bewegst, um deine Faszien zu stimulieren und Verspannungen zu lösen.\n\n"
        "Spüre, wie dein Rücken sich mit jedem Atemzug freier und leichter anfühlt.\n\n"
        "Starte jetzt und entdecke die Kraft des Bodens für eine junge und bewegliche Wirbelsäule!",
    'overlay': const Thumbnail('assets/thumbnails/5.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834210625/rendition/720p/file.mp4?loc=external&signature=3f9b6676bff9f989c2c87d29742f0405b07ad2888ab77beb8d3ed0bf9d594e43',
    'text': "Brace yourself – not only winter is coming",
    'shortDescription':
        "Du lernst deine tief liegende Bauchmuskulatur zu aktivieren.\n"
            "Beim so genannten „Bracing“ ziehst du deinen Bauchnabel zur Wirbelsäule.\n"
            "Deine Rumpfmuskulatur arbeitet wie ein stützendes Korsett.\n\n"
            "Video 1.6: Starte in Rückenlage\n"
            "1.\tRL Krokodilatmung\n"
            "2.\tKäfer\n"
            "3.\tKletternder Affe\n"
            "4.\tBaby Rolling\n"
            "5.\tGartenzwerg",
    'description': "Indem du deinen Bauchnabel zur Wirbelsäule ziehst, spannst du die tief liegende Bauchmuskulatur, insbesondere den Transversus Abdominis, an…\n\n"
        "diese Muskulatur fungiert als eine Art natürlicher Korsett um die Wirbelsäule herum.\n\n"
        "Die Aktivierung des Transversus Abdominis erhöht den intraabdominalen Druck und bietet deiner Wirbelsäule so eine bessere Stabilität.\n\n"
        "Die sogenannte „Bracing“-Technik wird eingesetzt, um Stabilität und Ausrichtung der Wirbelsäule während einer Übung zu verbessern.\n\n"
        "Du wirst lernen, wie du die korrekte Ausrichtung deines Beckens unterstützt und eine neutrale Wirbelsäulenposition förderst.\n\n"
        "So kannst du übermäßige Belastungen und Kompensationen vermeiden.",
    'overlay': const Thumbnail('assets/thumbnails/6.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834693321/rendition/720p/file.mp4?loc=external&signature=6261bb05c87834a21743844c19210583f654341e20bd246f7341483baf24c580',
    'text': "Wer anspannen kann muss auch loslassen können",
    'shortDescription': "Bei Kräftigungsübungen ist Spannung hilfreich.\n"
        "Im Alltag müssen wir unsere Spannung jedoch loslassen können.\n"
        "Lerne durch den Wechsel von Kräftigungs- und Lockerungsübungen die Spannungsverhältnisse deines Körpers selbst zu regulieren.\n"
        "P.S. Die Videoqualität wird nach der ersten Minute besser.\n\n"
        "Video 1.7: Starte in Rückenlage\n"
        "1.\tRolle zu Seitsitz\n"
        "2.\tKletternder Affe\n"
        "3.\tBaby Rolling\n"
        "4.\tGartenzwerg\n"
        "5.\tRL Nasenatmung",
    'description': "Willkommen zu einer neuen Perspektive auf Rückengesundheit!\n"
        "In diesem Video erkunden wir…\n\n"
        "das wichtige Zusammenspiel von Anspannen und Loslassen, speziell für Menschen mit Rückenschmerzen.\n\n"
        "Studien zeigen, dass während Kraftübungen die Bracing-Technik entscheidend ist.\n"
        "Doch wir wissen auch, dass Menschen mit Rückenschmerzen oft zu viel Spannung mit sich rumtragen. Es ist von großer Bedeutung, das Gleichgewicht zwischen Anspannen und Loslassen zu finden. Damit auch Du die aufgestaute Spannung loslassen kannst.\n\n"
        "Ein gesunder Rücken hängt nicht nur von körperlicher Stärke ab, sondern auch von der Fähigkeit, loszulassen und zu entspannen.\n\n"
        "Finde die Balance zwischen Anspannen und Loslassen, um deinem Rücken optimale Unterstützung zu bieten und deinen Alltag mit Leichtigkeit zu meistern.\n\n"
        "P.S. Die Videoqualität wird nach der ersten Minute besser.",
    'overlay': const Thumbnail('assets/thumbnails/7.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834162030/rendition/720p/file.mp4?loc=external&signature=b4c985a0d594777cc270695923946d1e62da641585ea3b43ead4a798104e194b',
    'text': "Gesunde Hüfte, Starker Rücken: Der Joint-by-Joint Ansatz",
    'shortDescription':
        "Du arbeitest an der Beweglichkeit deiner Hüfte und Brustwirbelsäule.\n"
            "Den beiden besten Ansatzpunkten zur Prävention von Rückenschmerzen.\n"
            "Denn fehlende Beweglichkeit in Hüften und BWS sorgt für eine übermäßige Beweglichkeit und Belastung des unteren Rückens.\n"
            "Mehr dazu findest du im Wissenstext.\n\n"
            "Video 1.8: Starte in Rückenlage\n"
            "1.\tRL Krokodilatmung\n"
            "2.\tKäfer mit Fersen ablegen\n"
            "3.\tRolle zu Seitsitz\n"
            "4.\tGartenzwerg\n"
            "5.\tSL Buch umblättern",
    'description': "Entdecke den Joint-by-Joint Ansatz und lerne, warum die Mobilität der Hüfte eine wichtige Rolle bei der Prävention von Rückenschmerzen spielt…\n\n"
        "In diesem Video tauchen wir in die faszinierende Welt der Gelenke ein und zeigen dir, wie du deine Hüfte mobilisieren kannst, um deinen Rücken zu stärken.\n\n"
        "Der Joint-by-Joint Ansatz betont die unterschiedlichen Anforderungen an die Gelenke unseres Körpers.\n\n"
        "Insbesondere unsere Hüfte benötigt eine gute Mobilität, während die Lendenwirbelsäule (LWS) eher stabile Eigenschaften aufweisen sollte.\n\n"
        "Wenn die Hüftmobilität eingeschränkt ist, versucht die LWS diese Einschränkung zu kompensieren, indem sie sich übermäßig bewegt.\n\n"
        "Das kann zu Überlastungen und Rückenschmerzen führen.\n\n"
        "Bist du bereit, die Rolle deiner Hüfte bei der Prävention von Rückenschmerzen zu erkunden?\n\n"
        "Dann komm mit uns auf diese spannende Reise zur Mobilität und Stabilität. Lass uns deine Hüfte befreien und deinem Rücken eine solide Basis geben!",
    'overlay': const Thumbnail('assets/thumbnails/8.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834164918/rendition/720p/file.mp4?loc=external&signature=45d1c93d42791c347b16796a68b2589f2afda2359c1be513a22d14be01c16499',
    'text':
        "Lösche den Brand statt die Batterie aus dem Rauchmelder zu ziehen.",
    'shortDescription': "Höre auf die Signale deines Körpers.\n"
        "Nutze die Abfolge von Entspannung, Kräftigung und Beweglichkeit (Hüfte & BWS) um präventiv an den wahren Ursachen von Rückenschmerzen anzusetzen.\n"
        "Achte auf eine langsame und gleichmäßige Ausführung.\n\n"
        "Video 1.9: Starte in Rückenlage\n"
        "1.\tRL Krokodilatmung\n"
        "2.\tKletternder Affe\n"
        "3.\tRückenroller\n"
        "4.\tGartenzwerg mit gestreckten Armen\n"
        "5.\tSL Buch umblättern",
    'description': "Stell dir vor, dein Körper ist wie ein Haus und Rückenschmerzen sind wie ein schrillender Rauchmelder...\n\n"
        "Du könntest versucht sein, den Alarm einfach abzustellen, aber was ist mit der eigentlichen Ursache des Problems?\n\n"
        "Wenn wir Schmerzen im Rücken verspüren, ist es wie der Alarm, der auf eine Verletzung oder ein anderes Problem hinweist.\n\n"
        "Es ist wichtig, den Schmerz nicht einfach zu ignorieren oder oberflächlich zu behandeln.\n\n"
        "Stell dir vor, du schmierst eine Schmerzsalbe auf deinen Rücken oder nimmst einfach nur Schmerzmedikamente ein, ohne die Hüfte oder deinen Schultergürtel zu untersuchen.\n\n"
        "Das wäre so, als würdest du die Batterie aus dem Rauchmelder entfernen, anstatt nach der eigentlichen Ursache des Alarms zu suchen.\n\n"
        "Lerne die Alarmglocken des Schmerzes zu verstehen und wie du die Hüfte als wichtigen Schlüssel zur Prävention und Linderung von Rückenschmerzen einsetzen kannst.",
    'overlay': const Thumbnail('assets/thumbnails/9.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834168208/rendition/720p/file.mp4?loc=external&signature=bd61c59014714c30bb3c76177d0f892a53aeff8945fabe137d8b630ae6eb4ced',
    'text': "Abschluss der ersten Stufe",
    'shortDescription':
        "Du kommst am Ende des Videos zum ersten Mal in den Vierfüßlerstand.\n"
            "Achte darauf, dass deine Hände unter den Schultern sind und Knie unter der Hüfte.\n"
            "Danach hast du die erste Stufe abgeschlossen.\n"
            "Herzlichen Glückwunsch!\n\n"
            "Video 1.10: Starte in Rückenlage\n"
            "1.\tRolle zu Seitsitz\n"
            "2.\tBaby Rolling\n"
            "3.\tEinzelellbogenstütz\n"
            "4.\tGartenzwerg mit gestreckten Armen\n"
            "5.\t4 Füßler zu Position des Kindes",
    'description': "Herzlichen Glückwunsch! Du hast die erste Stufe der motorischen Entwicklung gemeistert und begibst dich nun in eine neue Phase. Es wird Zeit sich ein Stockwerk nach oben zu bewegen und den Vierfüßlerstand zu meistern…\n\n"
        "Du bist auf dem Weg zu einem schmerzfreien und starken Rücken, bleib nun weiter dran, um Stück für Stück eine gesunde Gewohnheit zu etablieren.\n\n"
        "Du hast bereits den ersten Schritt gemacht und ich bin zuversichtlich, dass du auch die nächsten Etappen mit Bravour meistern wirst.\n\n"
        "Dein Feedback ist uns außerordentlich wichtig. Wir möchten sicherstellen, dass du die bestmögliche Erfahrung mit unserer App hast.\n\n"
        "Lass uns bitte ein Feedback da, wie dir die Übungsauswahl gefällt, ob du die Videos hilfreich findest und ob die Wissenstexte informativ sind. Deine Meinung zur Benutzung und dem Aussehen der App ist ebenfalls von großer Bedeutung.\n\n"
        "Darüber hinaus freuen wir uns über deine Wünsche für zukünftige Features. Welche Funktionen wünschst du dir, um dein Training noch effektiver zu gestalten?\n\n"
        "Lass uns wissen, wie wir deine Erfahrung weiter verbessern können, denn am Ende des Tages geht es darum, dass du das Beste aus dieser App herausholen kannst.\n\n"
        "Auf geht's, gemeinsam schaffen wir Großes!\n\n"
        "Dein BackQuest Team",
    'overlay': const Thumbnail('assets/thumbnails/10.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834170796/rendition/720p/file.mp4?loc=external&signature=d01fd0500cd3594b0f3cb62aef6642f9d7ffbeb93d3e6f950827c8ffed9ab49a',
    'text': "Krabbeln für eine starke Core-Stabilität und Antirotation",
    'shortDescription':
        "In der Anfangsentspannung lernst du ab jetzt die gleichmäßige Bewegung des Zwerchfells (Bauchatmung) und des Brustkorbs.\n"
            "Danach kommst du aus dem Vierfüßlerstand ins Krabbeln.\n"
            "Sind Arm und Hand gleichzeitig in der Luft, muss deine Rumpfmuskulatur arbeiten, um dich stabil zu halten.\n"
            "Dabei wird die Antirotation deiner Rumpfmuskulatur gekräftigt.\n\n"
            "Video 2.1: Starte in Rückenlage\n"
            "1.\tSynchronatmung\n"
            "2.\tBaby Rolling (BL Ellbogen unter Schulter)\n"
            "3.\tBL Einzelellebogenstütz (4 Füßler)\n"
            "4.\t4 Füßler zu Position des Kindes (4 Füßler)\n"
            "5.\tKrabbeln (4 Füßler)\n"
            "6.\tPosition des Kindes",
    'description': "Bereite dich darauf vor, deine Core-Muskulatur zu stärken und die Antirotation zu meistern!\n\n"
        "Erfahre, wie das Krabbeln nicht nur deine koordinativen Fähigkeiten verbessert, …\n"
        "sondern auch gezielt auf die Stärkung deiner Rumpfmuskulatur abzielt.\n\n"
        "Tauche ein in eine Welt des dynamischen Zusammenspiels von Bauch- und Rückenmuskeln, um unerwünschte Rotationen zu verhindern und deine Core-Stabilität zu maximieren.\n\n"
        "Lass uns gemeinsam krabbeln und die Grundlage für eine gesunde und stabile Körperhaltung schaffen.",
    'overlay': const Thumbnail('assets/thumbnails/11.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834694810/rendition/720p/file.mp4?loc=external&signature=50e709051251e35f284ba73d67c35d9a8547a7615dff76a69b72129ab794f76b',
    'text': "Höre auf deinen Körper!",
    'shortDescription':
        "Du mobilisierst deine Handgelenke, um sie beweglich und stark zu halten.\n"
            "Achte darauf, die Schultern weg von den Ohren zu ziehen.\n"
            "Lasse deinen Atem auch in der Dehnung weiter fließen.\n\n"
            "Video 2.2: Starte in Rückenlage\n"
            "1.\tTucked Hollow Body Krokodilatmung (RL gestreckt)\n"
            "2.\tBaby Rolling (BL Ellbogen)\n"
            "3.\t4 Füßler zu Position des Kindes (4Füßler)\n"
            "4.\tPinguinmobi(4Füßler)\n"
            "5.\t4Füßler zu Hocke (4Füßler)\n"
            "6.\tPosition des Kindes",
    'description': "Schmerz ist nur ein Signal deines Körpers und muss NICHT zwangsläufig auf eine Verletzung hinweisen. Deshalb wollen wir dir helfen, dieses Signal zu verstehen und die richtigen Maßnahmen zu ergreifen…\n\n"
        "Schmerz kann auch ein Weg deines Körpers sein, dir mitzuteilen, dass der umliegende Bereich verspannt ist und nach mehr Bewegung ruft.\n\n"
        "Denke immer daran: Schmerz ist nicht dein Feind, sondern ein Wegweiser zu einem gesünderen und beweglicheren Körper.\n\n"
        "Mit den richtigen Mobilisationsübungen kannst du deine Rückenschmerzen reduzieren und dich wieder frei und energiegeladen fühlen.\n\n"
        "Also, worauf wartest du? Klicke jetzt auf Play und entdecke die transformative Kraft der Mobilisationsübungen!",
    'overlay': const Thumbnail('assets/thumbnails/12.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834697298/rendition/720p/file.mp4?loc=external&signature=7a038d31756b419cd3322d5fabee05f186cf77787a62f045b7a41d8f527c9c10',
    'text':
        "Die Geheimnisse des Körper-Zusammenspiels enthüllt: Das Regional Interdependence Model",
    'shortDescription':
        "Du arbeitest an der Beweglichkeit deiner Hüfte und Brustwirbelsäule (BWS).\n"
            "Beide sind nach dem Regional Interdependence Modell von großer Bedeutung bei der Prävention von Rückenschmerzen.\n"
            "Achte beim Einzelellbogenstütz (3. Übung) darauf, den Bauchnabel zur Wirbelsäule zu ziehen, um den unteren Rücken zu entlasten.\n\n"
            "Video 2.3: Starte in Rückenlage\n"
            "1.\tSynchronatmung\n"
            "2.\tRolle zu Seitsitz\n"
            "3.\tEinzelellbogenstütz\n"
            "4.\t4 Füßler zu Position des Kindes\n"
            "5.\tBWS Mobi Ellbogen\n"
            "6.\tChilds Pose abgelegt",
    'description': "Hey du! Bist du es leid, immer nur Symptome zu behandeln, ohne die eigentliche Ursache deiner Schmerzen zu finden? Dann haben wir etwas Aufregendes für dich!\n\n"
        "Schluss mit der traditionellen Herangehensweise, … bei der nur der schmerzende Bereich behandelt wird!\n\n"
        "Die Lösung kann möglicherweise in einer ganz anderen Region deines Körpers liegen. Klingt verrückt, oder? Aber es ist wahr!\n\n"
        "Lass uns ein Beispiel geben: Hast du schon einmal Schmerzen im unteren Rücken gehabt?\n"
        "Nun, nach dem Regional Interdependence Model könnten die eigentlichen Probleme in deiner Hüfte, der Brustwirbelsäule oder im Schultergürtel liegen.\n\n"
        "Unglaublich, oder? Dein Körper ist ein Meister der Kompensation, und manchmal versucht er, Dysfunktionen in anderen Bereichen auszugleichen, was dann zu Schmerzen an unerwarteten Stellen führt.\n\n"
        "Alle Videos zielen darauf ab, nicht nur die Symptome zu lindern, sondern auch die zugrunde liegenden Ursachen anzugehen.\n\n"
        "Mit gezielten Bewegungs- und Stabilisationsübungen und Entspannungstechniken wirst du den Körper-Zusammenhang auf eine ganz neue Art und Weise erleben.\n\n"
        "Also, schnapp dir deinen Lieblingsplatz, drück auf Play und lass uns gemeinsam die faszinierende Welt des Körper-Zusammenspiels erkunden!\n\n"
        "Befreie dich von den Fesseln der traditionellen Behandlungsansätze und entdecke das Regional Interdependence Model für dich selbst.",
    'overlay': const Thumbnail('assets/thumbnails/13.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834174282/rendition/720p/file.mp4?loc=external&signature=76a45c181958e2952e4ed4e308c3eb3330384d6651e01f8825290af73521a129',
    'text': "Starke Handgelenke: Die Geheimwaffe gegen Verletzungen",
    'shortDescription': "Du setzt wieder den Fokus auf die Handgelenke.\n"
        "Erst kräftigend mit der Hüftdrehung im Bärenhalt – lerne dich auf einer Hand zu stabilisieren!\n"
        "Danach mobilisierst du deine Handgelenke – achte darauf, die Schultern weg von den Ohren fallen zu lassen!\n\n"
        "Video 2.4: Starte in Rückenlage\n"
        "1.\tTucked Hollow Body Krokodilatmung\n"
        "2.\tBaby Rolling\n"
        "3.\t4 Füßler zu Position des Kindes\n"
        "4.\tBär Hüftdrehung\n"
        "5.\tHandgelenkmobi\n"
        "6.\tKrabbeln",
    'description': "Bist du bereit, deine Handgelenke zu stärken und Verletzungen vorzubeugen?\n\n"
        "Tauche ein in die faszinierende Welt der Handgelenksgesundheit und …\n\n"
        "entdecke die Vorteile der Handgelenksgymnastik. Wir zeigen dir, wie du Flexibilität, Stabilität und Kraft deiner Handgelenke verbessern kannst.\n\n"
        "Gemeinsam stärken wir die Muskulatur rund um die Handgelenke und sorgen für eine bessere Durchblutung, um Nährstoffe effizienter zu transportieren und Verletzungsrisiken zu minimieren.\n\n"
        "Erfahre, wie Handgelenksgymnastik Überlastungsschäden vorbeugen kann, insbesondere für diejenigen, die häufig am Computer arbeiten oder repetitive Handbewegungen ausführen.\n\n"
        "Dann komm mit uns auf diese spannende Reise und mach dich bereit für starke und gesunde Handgelenke!",
    'overlay': const Thumbnail('assets/thumbnails/14.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834178314/rendition/720p/file.mp4?loc=external&signature=4b1cd078f73715c70aef6738fa0a1f1e2ad63800490a752fd632d80e1cb24e27',
    'text': "Starke Schulterblätter für eine kraftvolle und gesunde Schulter",
    'shortDescription':
        "Du setzt den Fokus auf die Bewegung deiner Schulterblätter.\n"
            "Im PushUp+ lernst du deine Schulterblätter aktiv anzusteuern.\n"
            "Das gelernte überträgst du dann im Herabschauenden Hund in eine andere Bewegungsebene.\n\n"
            "Video 2.5: Starte in Rückenlage\n"
            "1.\tSynchronatmung\n"
            "2.\tRolle zu Seitsitz\n"
            "3.\tHip Swifel + Lehnen\n"
            "4.\t4 Füßler Push Up +\n"
            "5.\t4 Füßler zu Herabschauender Hund\n"
            "6.\tEinarmig Childs Pose Mobi",
    'description': "Ein starkes Schulterblatt ist der Schlüssel zu einer leistungsfähigen und verletzungsfreien Schulter…\n\n"
        "Entdecke effektive Übungen und Techniken, um deine Schulterblattmuskulatur zu stärken und die optimale Ausrichtung des Arms zu erreichen.\n\n"
        "Erfahre, wie du unerwünschte Kompensationsbewegungen vermeidest und die Belastung auf Muskeln und Sehnen reduzierst.\n\n"
        "Mit einer starken und funktionalen Schulterblattmuskulatur bist du bereit, deine sportlichen Ziele zu erreichen und Verletzungen vorzubeugen.\n\n"
        "Bist du bereit, dein Schulterblatt auf das nächste Level zu bringen?",
    'overlay': const Thumbnail('assets/thumbnails/15.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834182013/rendition/720p/file.mp4?loc=external&signature=d48b455115b96f5456c69fa739379bea2d6f635e7944caa9e57b9743ee233a4b',
    'text': "Die versteckte Verbindung unser Füße zu Rückenschmerzen",
    'shortDescription':
        "Du lernst deine Hüfte besser anzusteuern und zu stabilisieren.\n"
            "Anschließend arbeitest du an der Mobilität und Kraft deiner Füße.\n"
            "Besonders deiner Plantarfaszie – auf den Unterseiten der Füße.\n"
            "Die haben nach dem Regional Interdepenence Modell einen direkten Einfluss auf Rückenschmerzen.\n\n"
            "Video 2.6: Starte in Rückenlage\n"
            "1.\tTucked Hollow Body Krokodilatmung\n"
            "2.\tToter Käfer\n"
            "3.\t4 Füßler zu Childs Pose\n"
            "4.\tBärenhocke\n"
            "5.\tBWS Mobi Ellbogen\n"
            "6.\tChilds Pose",
    'description': "Entdecke die versteckte Verbindung zwischen der hinteren Kette deines Körpers und der Plantarfaszie in deinen Füßen für einen starken und schmerzfreien Rücken…\n\n"
        "Erfahre mehr über die Auswirkungen einer verhärteten oder verkürzten Plantarfaszie auf die gesamte hintere Kette und wie dies zu Rückenschmerzen führen kann.\n\n"
        "Lerne gezielte Übungen und Mobilisationstechniken kennen, um deine Körperhaltung zu verbessern, die Flexibilität zu steigern und Rückenschmerzen zu reduzieren.\n\n"
        "Lerne mehr über effektive Strategien, um deine Wirbelsäule zu entlasten!",
    'overlay': const Thumbnail('assets/thumbnails/16.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834185765/rendition/720p/file.mp4?loc=external&signature=a3782acb43f626a0230536755a0dd0991c05ffba28dbdef057b7920b1c8ed351',
    'text': "Warum gibt es so wenig statisches Dehnen in den Videos?",
    'shortDescription': "Du arbeitest im Seitsitz an der Mobilität deiner Hüfte.\n"
        "Achte auf langsame und gleichmäßige Bewegungen.\n"
        "Anschließend noch an der Mobilität und Stabilität im Schultergürtel mit dem Herabschauenden Hund.\n"
        "Schiebe dabei dein Gesäß zur Decke und den Brustkorb zu den Knien.\n\n"
        "Video 2.7: Starte in Rückenlage\n"
        "1.\tSynchronatmung\n"
        "2.\tRolle zu Seitsitz\n"
        "3.\tSwifel zu Sprunggelenkmobi\n"
        "4.\tKrabbeln\n"
        "5.\t4 Füßler zu Herabschauender Hund\n"
        "6.\tEinarmige Childs Pose",
    'description': "Entfessle deine Beweglichkeit - Das Geheimnis der Mobility!\n"
        "Willst du deinen Körper in vollem Umfang bewegen können? …\n"
        "Möchtest du deine Beweglichkeit verbessern und gleichzeitig stabil und kontrolliert agieren? Dann ist es Zeit für Mobility!\n\n"
        "Mobility ist mehr als nur einfaches Dehnen. Kurz gesagt ist Mobility= Flexibilität (passiv) + motorische Kontrolle (aktiv) + Kraft. \n\n"
        "Es ist ein aktiver Ansatz, der es dir ermöglicht, Bewegungseinschränkungen zu identifizieren und zu überwinden. Gemeinsam werden wir gezielte Mobilisationsübungen durchführen, die deine Gelenke und umliegenden Strukturen auf sanfte und doch effektive Weise mobilisieren. \n\n"
        "Du wirst spüren, wie deine Beweglichkeit Schritt für Schritt zunimmt und du deinen Körper in vollen Zügen genießen kannst.\n\n"
        "Der große Vorteil von Mobility gegenüber statischem Dehnen liegt in der Nachhaltigkeit und Übertragbarkeit auf den Sport. Du wirst nicht nur flexibler, sondern auch stabiler und kontrollierter in deinen Bewegungen. \n\n"
        "Dein Nervensystem wird aktiviert und deine sensorische Wahrnehmung geschult, so dass du eine bessere Körperkontrolle entwickelst und Verletzungsrisiken minimierst.",
    'overlay': const Thumbnail('assets/thumbnails/17.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834189198/rendition/720p/file.mp4?loc=external&signature=5c6a59cd918e123538058e8d7e81f59b976f2b5acc76594a27f4e5a4a360704f',
    'text': "Die Landkarten der Bewegung",
    'shortDescription':
        "Nun wechselt du im Seitsitz die Positionen – leite die Bewegung aus dem Knie zuerst ein.\n"
            "Denke daran den Atem weiter fließen zu lassen.\n"
            "Beim Aufrotieren der Brustwirbelsäule folgt dein Blick der Hand durch die ganze Bewegung.\n\n"
            "Video 2.8: Starte in Rückenlage\n"
            "1. Tucked Hollow Body Krokodilatmung\n"
            "2. Baby Rolling\n"
            "3. Kletternder Affe\n"
            "4. Rolle zum Seitsitz\n"
            "5. Großer Gartenzwerg\n"
            "6. BWS Aufblättern",
    'description': "Schon seit unseren Kindesbeinen speichert unser Gehirn alle Bewegungsmuster. Ob Krabbeln, gehen oder greifen…\n\n"
        "Das Ganze können wir uns vorstellen wie Straßen. Wird eine Bewegung nur ein paar Mal ausgeführt entsteht ein Trampelpfad durch eine dicht bewachsene Wiese.\n\n"
        "Umso öfter wird die Bewegung nun ausführen, desto mehr entwickelt sich der Trampelpfad zu einem Feldweg. Der Körper kann das Bewegungsprogramm leichter und ohne Nachdenken abrufen.\n\n"
        "Die Bewegung wird ökonomisch, fließend und rund. Die zeitliche Aktivierung der Muskeln verbessert sich und wir brauchen immer weniger Muskelkraft.\n\n"
        "Ein aktives Mobility Training stimuliert 10x mehr Rezeptoren im Gehirn als passives Dehnen. Sowohl von Rezeptoren für das Lernen als auch für das Abspeichern von Bewegungen.\n\n"
        "So kann aus einem Feldweg eine Straße werden.\n\n"
        "Bieten wir unserem Körper nun auch noch zahlreiche Übungsvarianten. In verschiedene Bewegungsrichtungen. Auf verschiedenen Untergründen.\n\n"
        "Dann kann aus einer Straße eine breite Autobahn werden. Auf der man nicht ins Straucheln gerät oder sich verletzt, wenn man leicht vom Weg abkommt. Sondern immer harmonisch mit möglichst wenig Muskelkraft vorwärtskommt.",
    'overlay': const Thumbnail('assets/thumbnails/18.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834192567/rendition/720p/file.mp4?loc=external&signature=adb2f230f7c11b513fd96d5a86e48308aeebf7dfdd6f89279b3b299344a1d1e0',
    'text': "Die einzig „richtige“ Sitzposition ist immer die nächste!",
    'shortDescription':
        "Im Toten Käfer kräftigst du deine Rumpfmuskulatur – ziehe dabei den Bauchnabel zur Wirbelsäule.\n\n"
            "Anschließend lockerst du dich beim Baby Rolling – achte darauf die Beine locker zu lassen!\n\n"
            "Nach einer Vorbereitung der Handgelenke kräftigst du deine einarmige Stützkraft.\n\n"
            "Video 2.9: Starte in Rückenlage\n"
            "1. Synchronatmung\n"
            "2. Toter Käfer\n"
            "3. Baby Rolling\n"
            "4. 4 Füßler zu Position des Kindes\n"
            "5. Handgelenkmobi\n"
            "6. Bär Hüftdrehung",
    'description': "Lange wurde erzählt, dass wir immer in einer perfekt gerade Körperhaltung sitzen müssten, um Rückenschmerzen vorzubeugen…\n\n"
        "In neueren Forschungen zeigt sich aber, dass unsere Körperhaltung einen viel kleineren Einfluss auf Schmerzen hat als bisher angenommen.\n\n"
        "Der menschliche Körper ist für Bewegung gemacht - er sehnt sich nach Veränderung und Variation. Wenn wir lange Stunden in einer starren Sitzposition verharren, fühlen sich unsere Muskeln und Gelenke eingeschränkt und steif an.\n\n"
        "Unser Körper schreit förmlich nach Bewegung, um die Spannung zu lösen und die Durchblutung zu fördern.\n\n"
        "Die Lösung liegt in der Vielfalt und Bewegung! Indem wir regelmäßig unsere Sitzposition verändern, aufstehen, uns dehnen und kleine Bewegungspausen einlegen, geben wir unserem Körper genau das, was er braucht - Abwechslung und Entlastung.\n\n"
        "Unser Körper wird es uns danken, indem er geschmeidiger und flexibler wird.\n\n"
        "Bereit, deinen Körper zu befreien und ihm die Variation zu geben, nach der er sich sehnt?\n\n"
        "Dann schnapp dir deinen Stuhl, finde bequeme Kleidung und lass uns gemeinsam einen Schritt in Richtung eines bewegten und schmerzfreien Lebens machen.",
    'overlay': const Thumbnail('assets/thumbnails/19.gif'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834195887/rendition/720p/file.mp4?loc=external&signature=fbe59575c124e4b9a00e49619e82925656ae1478912e7d2c0423bb4562f39787',
    'text': "Glückwunsch schon bald hast du die Stufe 2 abgeschlossen!",
    'shortDescription': "Du hast die zweite Stufe nun so gut wie geschafft.\n\n"
        "Der Fokus liegt nochmal auf der Bewegung deiner Schulterblätter und der Stabilität im Schultergürtel.\n\n"
        "Zum Abschluss mobilisierst du noch deine Brustwirbelsäule (BWS) – der Blick folgt deinem Ellbogen in der ganzen Bewegung.\n\n"
        "Video 2.10: Starte in Rückenlage\n"
        "1. Tucked Hollow Body Krokodilatmung\n"
        "2. 4 Füßler zu Position des Kindes\n"
        "3. 4 Füßler Push Up +\n"
        "4. 4 Füßler zu Herabschauender Hund\n"
        "5. 4 Füßler BWS Mobi\n"
        "6. Childs Pose mit abgelegten Ellbogen",
    'description': "Herzlichen Glückwunsch! Du hast erfolgreich das Ende der ersten Testversion erreicht und ich möchte dir meinen aufrichtigen Glückwunsch aussprechen! Du hast kontinuierlich an deiner Rückenschmerzprävention gearbeitet und ...\n\n"
        "bist auf dem richtigen Weg zu einem gesunden und schmerzfreien Rücken.\n\n"
        "Während dieser ersten Etappe hast du wertvolles Wissen über deinen Körper und verschiedene Übungen erlangt. Du hast gelernt, wie wichtig es ist, deinem Rücken regelmäßig Aufmerksamkeit zu schenken und ihn durch gezielte Übungen zu stärken. Dein Engagement und deine Ausdauer sind bewundernswert, und ich bin stolz darauf, dass du bis hierhin gekommen bist.\n\n"
        "Aber das ist erst der Anfang! In den kommenden Wochen werden wir nach und nach neue Trainings-, Wissens- und Entspannungsinhalte einführen, um deine Rückenschmerzprävention noch effektiver und abwechslungsreicher zu gestalten. Du darfst dich auf spannende und neue Herausforderungen freuen, die dich dabei unterstützen, deinen Rücken weiter zu stärken und deine Flexibilität zu verbessern.\n\n"
        "Aber wir hören nicht nur bei den Inhalten auf. Wir möchten deine Erfahrung mit unserer App kontinuierlich verbessern und auf deine Bedürfnisse eingehen. Daher freuen wir uns immer über dein Feedback! Teile uns mit, wie dir die bisherigen Übungen, Wissenstexte und Entspannungsinhalte gefallen haben. Lass uns wissen, welche neuen Features du dir wünschst und wie wir deine Trainingsroutine noch besser gestalten können.\n\n"
        "Vielen Dank im Voraus! Mit deiner Hilfe können wir gemeinsam etwas Besonderes erschaffen!",
    'overlay': const Thumbnail('assets/thumbnails/20.gif'),
  },
];

getVideoList() {
  return _videoList;
}

class Levels extends StatelessWidget {
  const Levels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseService().getLevelDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          Map<String, dynamic> levelData = snapshot.data!;

          List<Widget> videoWidgets = List.generate(_videoList.length, (index) {
            int levelNumber = index + 1;
            bool isLocked = levelData['level$levelNumber'] ?? false;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              child: Column(
                children: [
                  VideoPlayerView(
                    path: _videoList[index]['path'],
                    text: _videoList[index]['text'],
                    shortDescription: _videoList[index]['shortDescription'],
                    description: _videoList[index]['description'],
                    overlay: _videoList[index]['overlay'],
                    locked: !isLocked,
                  ),
                  const Divider(
                    // Add a separation line after each video widget
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ],
              ),
            );
          });

          return SingleChildScrollView(
            child: Column(
              children: videoWidgets,
            ),
          );
        } else {
          return const Text('No data available.');
        }
      },
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    Key? key,
    this.order,
    required this.path,
    required this.text,
    required this.description,
    required this.shortDescription,
    required this.overlay,
    required this.locked,
  }) : super(key: key);

  final int? order;
  final String path;
  final String text;
  final String description;
  final String shortDescription;
  final Widget overlay;
  final bool locked;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  FirebaseService firebaseService = FirebaseService();

  String? userId;

  int level = 0;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  bool isClicked = false;
  Duration? videoDuration;

  Future<void> initializeVideo() async {
    /*videoPlayerController = VideoPlayerController.asset(
      widget.path,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );*/

    videoPlayerController = VideoPlayerController.network(
      widget.path,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );

    await videoPlayerController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: false,
      looping: false,
    );

    Wakelock.enable();

    setState(() {});

    userId = await getUserId();

    videoPlayerController!.addListener(videoProgressListener);
  }

  void updateLevel() async {
    int increasedOrder = widget.order! + 1;
    String levelField = 'level$increasedOrder';
    bool completionStatus = true;
    int totalLevels = 0;

    Map<String, dynamic> leveldataUpdate = {
      levelField: completionStatus,
    };

    DocumentSnapshot leveldataSnapshot = await FirebaseFirestore.instance
        .collection('Leveldata')
        .doc(userId)
        .get();

    if (leveldataSnapshot.exists) {
      Map<String, dynamic>? levelData =
          leveldataSnapshot.data() as Map<String, dynamic>?;

      levelData!.forEach((key, value) {
        if (value == true) {
          totalLevels++;
        }
      });
    }

    Map<String, dynamic> userdataUpdate = {
      'totalLevels': totalLevels,
    };

    FirebaseFirestore.instance
        .collection('Leveldata')
        .doc(userId)
        .set(leveldataUpdate, SetOptions(merge: true));

    FirebaseFirestore.instance
        .collection('Userdata')
        .doc(userId)
        .set(userdataUpdate, SetOptions(merge: true));

    // Update local data
    //firebaseService.saveDataLocally(leveldataUpdate);
    //firebaseService.saveDataLocally(userdataUpdate);
  }

  // Define a variable to store the last watched position.
  Duration lastWatchedPosition = Duration.zero;
  Duration watchedDuration = Duration.zero;

  void videoProgressListener() {
    if (chewieController != null) {
      final position = chewieController!.videoPlayerController.value.position;
      final duration = chewieController!.videoPlayerController.value.duration;
      final halfwayDuration = duration * 0.5;

      // Calculate the difference between the current position and the last watched position.
      final difference = position - lastWatchedPosition;

      // If the difference is greater than 5 seconds, don't count it as watched.
      if (difference < const Duration(seconds: 5)) {
        watchedDuration += difference;
      }

      // Update the last watched position to the current position.
      lastWatchedPosition = position;

      if (watchedDuration > halfwayDuration) {
        updateLevel();
      }
    }
  }

  Future<String?> getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locked == true) {
      return Column(
        children: [
          Container(
            height: 200,
            width: 800,
            margin: const EdgeInsets.symmetric(vertical: 50.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 153, 152, 152),
              border: Border.all(
                width: 2,
                color: const Color.fromARGB(255, 153, 152, 152),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const InkWell(
              child: Thumbnail('assets/thumbnails/locked.png'),
            ),
          ),
          VideoText(widget.text, widget.description, widget.shortDescription),
        ],
      );
    }

    if (isClicked == false) {
      return Column(
        children: [
          Container(
            height: 200,
            width: 800,
            margin: const EdgeInsets.symmetric(vertical: 50.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 153, 152, 152),
              border: Border.all(
                width: 2,
                color: const Color.fromARGB(255, 153, 152, 152),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: InkWell(
              child: widget.overlay,
              onTap: () {
                setState(() {
                  initializeVideo();
                  isClicked = true;
                });
              },
            ),
          ),
          VideoText(widget.text, widget.description, widget.shortDescription),
        ],
      );
    }

    if (chewieController == null) {
      return Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 100,
            width: 50,
            margin: const EdgeInsets.symmetric(vertical: 100.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                MaterialColor(0xFF409AB5, color),
              ),
            ),
          ),
          VideoText(widget.text, widget.description, widget.shortDescription),
        ],
      );
    }

    return Column(
      children: [
        Container(
          height: 200,
          width: 800,
          margin: const EdgeInsets.symmetric(vertical: 50.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 153, 152, 152),
            border: Border.all(
              width: 2,
              color: const Color.fromARGB(255, 153, 152, 152),
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Chewie(
            controller: chewieController!,
          ),
        ),
        VideoText(widget.text, widget.description, widget.shortDescription),
      ],
    );
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    Wakelock.disable();
    super.dispose();
  }
}

class VideoText extends StatefulWidget {
  const VideoText(this.text, this.description, this.shortDescription, {super.key});

  final String text;
  final String description;
  final String shortDescription;

  @override
  _VideoTextState createState() => _VideoTextState();
}

class _VideoTextState extends State<VideoText> {
  bool showDescription = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Text(
            widget.shortDescription,
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showDescription = !showDescription;
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 2,
                  color: Color.fromARGB(255, 153, 152, 152),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showDescription ? 'Wissenswertes' : 'Wissenswertes',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      showDescription
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDescription)
          Container(
            padding: const EdgeInsets.only(left: 15.0, top: 10.0),
            child: Text(
              widget.description,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
          ),
      ],
    );
  }
}

class Thumbnail extends StatelessWidget {
  const Thumbnail(this.path, {super.key});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class FullView extends StatelessWidget {
  const FullView({
    Key? key,
    this.order,
    required this.path,
    required this.text,
    required this.shortDescription,
    required this.description,
    required this.overlay,
  }) : super(key: key);

  final int? order;
  final String path;
  final String text;
  final String shortDescription;
  final String description;
  final Widget overlay;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Move your behavior here that you want to execute when leaving the view.
        int increasedOrder = order! + 1;
        final firebaseService =
            Provider.of<FirebaseService>(context, listen: false);
        final levelDataStream = firebaseService.getLevelDataStream();

                levelDataStream.listen((levelData) {
                  if (levelData.containsKey('level$increasedOrder')) {
                    bool isLevelComplete =
                        levelData['level$increasedOrder'] ?? false;
                    if (isLevelComplete) {
                      showDialog(
                        context: context,
                        builder: (_) => AssetGiffDialog(
                          image: Image.asset(
                            "assets/completed.gif",
                            fit: BoxFit.fitWidth,
                            width: 90,
                          ),
                          title: const Text(
                            "Level Abgeschlossen",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          description: const Text(
                            "Ein weiterer Schritt zur Rückengesundheit",
                            textAlign: TextAlign.center,
                            style: TextStyle(),
                          ),
                          entryAnimation: EntryAnimation.top,
                          onOkButtonPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AssetGiffDialog(
                          image: Image.asset(
                            "assets/not.png",
                            fit: BoxFit.fitWidth,
                            width: 90,
                          ),
                          title: const Text(
                            "Level Nicht geschafft",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          description: const Text(
                            "Nur du selbst kannst deine Rückenschmerzen bekämpfen",
                            textAlign: TextAlign.center,
                            style: TextStyle(),
                          ),
                          entryAnimation: EntryAnimation.top,
                          onOkButtonPressed: () {
                            Navigator.of(context).pop();
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                        ),
                      );
                    }
                  }
                });
              },
              child: const Text('Abschließen'),
            ),
          ],
        await for (var levelData in levelDataStream) {
          if (levelData.containsKey('level$increasedOrder')) {
            bool isLevelComplete = levelData['level$increasedOrder'] ?? false;
            if (isLevelComplete) {
              showDialog(
                context: context,
                builder: (_) => AssetGiffDialog(
                  image: Image.asset(
                    "assets/completed.gif",
                    fit: BoxFit.fitWidth,
                    width: 90,
                  ),
                  title: Text(
                    "Level Abgeschlossen",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  description: Text(
                    "Ein weiterer Schritt zur Rückengesundheit",
                    textAlign: TextAlign.center,
                    style: TextStyle(),
                  ),
                  entryAnimation: EntryAnimation.top,
                  onOkButtonPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (_) => AssetGiffDialog(
                  image: Image.asset(
                    "assets/tryagain.jpg",
                    fit: BoxFit.fitWidth,
                    width: 90,
                  ),
                  title: Text(
                    "Willst du schon aufhören?",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  description: Text(
                    "Wenn du zum Menü zurück gehst verlierst du deinen Fortschritt",
                    textAlign: TextAlign.center,
                    style: TextStyle(),
                  ),
                  entryAnimation: EntryAnimation.top,
                  onOkButtonPressed: () {
                    Navigator.of(context).pop();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              );
            }
          }
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(text),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: VideoPlayerView(
                  order: order,
                  path: path,
                  text: "",
                  shortDescription: shortDescription,
                  description: description,
                  overlay: overlay,
                  locked: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
