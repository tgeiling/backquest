library videos;

import 'dart:io';

import 'package:backquest/data_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:giff_dialog/giff_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

Map<int, Color> color = {
  50: Color.fromRGBO(64, 154, 181, .1),
  100: Color.fromRGBO(64, 154, 181, .2),
  200: Color.fromRGBO(64, 154, 181, .3),
  300: Color.fromRGBO(64, 154, 181, .4),
  400: Color.fromRGBO(64, 154, 181, .5),
  500: Color.fromRGBO(64, 154, 181, .6),
  600: Color.fromRGBO(64, 154, 181, .7),
  700: Color.fromRGBO(64, 154, 181, .8),
  800: Color.fromRGBO(64, 154, 181, .9),
  900: Color.fromRGBO(64, 154, 181, 1),
};

List<Map<String, dynamic>> _videoList = [
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834199066/rendition/720p/file.mp4?loc=external&signature=7ccaddbc42656a8dabed22fd305723431732333803baa30812e0ef827ee38028',
    'text': "Der Anfang deiner Rückengesundheit: Schritt für Schritt",
    'description': "Willkommen bei BackQuest, deinem persönlichen Begleiter auf dem Weg zu einem gesunden Rücken! Mache mit diesem Video den ersten Schritt und entscheide dich für eine positive Veränderung. " +
        "Denke bitte daran das hier ist nur unsere erste Testversion und ist noch weit von der Vision entfernt, die wir eines Tages erreichen wollen. Dafür brauchen wir DICH! " +
        "Mit deinem Feedback, deinen Erfahrungen und deinen Wünschen können wir eine einzigartige App entwickeln um so viel Menschen wie möglich zu helfen! " +
        "Dieses Video ist der Beginn einer neuen Gewohnheit. Ich weiß, dass es nicht immer einfach ist, aber sei geduldig mit dir selbst. Jeder kleine Fortschritt ist ein Schritt in die richtige Richtung." +
        "Manchmal wenn wir einen neuen Weg in unserem Leben einschlagen wollen, fühlt es sich an als würden wir in tiefem Schlamm laufen. Unsere Schuhe werden mit jedem Schritt schwerer und jeder Schritt kostet mehr Anstrengung. " +
        "Gerade dann lohnt es sich aufzuschauen, manchmal sieht man erst dann dass es noch einen anderen Weg gibt." +
        "BackQuest – Der einfache Weg zur Rückengesundheit",
    'overlay': Thumbnail('assets/thumbnails/level_1/1_1.jpeg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834201612/rendition/720p/file.mp4?loc=external&signature=4be3cb1a0d128710d08a3f60fd3c18c0d0df257ee53d7484f9af9732279eb124',
    'text': "Entspannter Atem – Entspannter Rücken",
    'description':
        "Wie du im letzten Video gemerkt hast starten wir am Anfang oft mit einer kurzen Atemmethode. Gönn dir damit eine wohlverdiente Auszeit vom Alltagsstress und schenke dir und deinem Rücken einen Moment der Ruhe. " +
            "Aktiviere damit dein parasympathisches Nervensystem. Spüre, wie der Stress von dir abfällt und eine Atmosphäre von Ruhe und Gelassenheit sich in dir ausbreitet. Erst entspannt entfalten die folgenden Dehn- und Mobilisationsübungen ihr ganzes Potenzial. ",
    'overlay': Thumbnail('assets/thumbnails/level_1/1_2.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/842179506/rendition/720p/file.mp4?loc=external&signature=0f91f0270a14634eb0e75118f5cf1588c5197ed87fb401fdb55a05d786382717',
    'text': "Roll dich gesund",
    'description':
        "Bereit für ein Abenteuer, das deinen Rücken stärkt und dich von Schmerzen befreit? In diesem Video lernst du die faszinierende Welt des Baby Rollings kennen, einer Methode zur Prävention von Rückenschmerzen. Es basiert auf der Bewegungsentwicklung von Säuglingen und Kleinkindern, die das Rollen erlernen, um ihre motorischen Fähigkeiten zu entwickeln. " +
            "Leider haben viele Erwachsene verlernt sich ohne die Kraft ihrer Beine zu rollen. Versuche die Bewegung nur über die Bewegung deiner Arme einzuleiten und spüre, wie deine Rumpfmuskulatur die Bewegung weiter überträgt. Deine Körperwahrnehmung, Koordination und Wohlbefinden sich verbessern. ",
    'overlay': Thumbnail('assets/thumbnails/level_1/1_3.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834206245/rendition/720p/file.mp4?loc=external&signature=5a565e80adb8ad094c3ee29099922c508aac2de8dbacac5eee55761611529ee5',
    'text':
        "Proximale Stabilität für distale Mobilität: Stärke deinen Kern für bessere Beweglichkeit",
    'description':
        "Bereit, deinen Körper auf ein neues Level der Beweglichkeit zu bringen? In diesem Video erfährst du alles über das Prinzip der proximalen Stabilität für distale Mobilität. " +
            "Dieses grundlegende Konzept der Sport- und Physiotherapie besagt, dass eine stabile und kontrollierte Rumpfmuskulatur (proximale Stabilität) die Vorraussetung schafft, dass die Muskeln und Gelenke in den entfernten Körperregionen (distale Mobilität) frei und effizient arbeiten können. " +
            "Stärke deinen Kern und erlebe die Freude an einem geschmeidigen und beweglichen Körper!",
    'overlay': Thumbnail('assets/thumbnails/level_2/2_1.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834208309/rendition/720p/file.mp4?loc=external&signature=43647bcbdbab7cd1066b2710ae2e2587531e15dcc0b8d4dcce11ccfa06a87b5d',
    'text': "Faszienrollen ohne Rolle: Befreie deinen Rücken mit Bodenübungen",
    'description':
        "Bist du bereit, deinen Rücken zu befreien und dich von Verspannungen zu lösen? In diesem Video zeigen wir dir, wie du Faszienrollen ganz ohne Rolle verwenden kannst – mit einfachen Bodenübungen für deinen Rücken. " +
            "Du brauchst keine teure Ausrüstung, denn der Boden wird zu deinem besten Freund. Wir führen dich durch eine Reihe von gezielten Übungen, bei denen du deinen Körper sanft auf dem Boden bewegst, um deine Faszien zu stimulieren und Verspannungen zu lösen. " +
            "Spüre, wie sich dein Rücken mit jedem Atemzug freier und leichter anfühlt. Sei dabei und entdecke die Kraft des Bodens für eine junge und bewegliche Wirbelsäule! ",
    'overlay': Thumbnail('assets/thumbnails/level_2/2_2.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834210625/rendition/720p/file.mp4?loc=external&signature=3f9b6676bff9f989c2c87d29742f0405b07ad2888ab77beb8d3ed0bf9d594e43',
    'text': "Brace yourself – not only winter is coming",
    'description':
        "Indem du deinen Bauchnabel zur Wirbelsäule ziehst, spannst du die tief liegende Bauchmuskulatur, insbesondere den Transversus Abdominis, an. Diese Muskulatur fungiert als eine Art natürlicher Korsett um die Wirbelsäule herum. Durch die Aktivierung des Transversus Abdominis wird die intraabdominale Druckerzeugung erhöht, was zu einer besseren Stabilität der Wirbelsäule führt. " +
            "Die sogenannte „Bracing“- Technik wird eingesetzt um die Stabilität und Ausrichtung der Wirbelsäule während einer Übung zu verbessern. Du wirst lernen, wie du die korrekte Ausrichtung deines Beckens unterstützt und eine neutrale Wirbelsäulenposition förderst, um übermäßige Belastungen und Kompensationen zu vermeiden. ",
    'overlay': Thumbnail('assets/thumbnails/level_2/2_3.jpeg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834693321/rendition/720p/file.mp4?loc=external&signature=6261bb05c87834a21743844c19210583f654341e20bd246f7341483baf24c580',
    'text': "Wer anspannen kann muss auch loslassen können",
    'description':
        "Willkommen zu einer neuen Perspektive auf Rückengesundheit! In diesem Video erkunden wir das wichtige Zusammenspiel von Anspannen und Loslassen, speziell für Menschen mit Rückenschmerzen. " +
            "Studien zeigen, dass während Kraftübungen die Bracing-Technik entscheidend ist. Doch wir wissen auch, dass Menschen mit Rückenschmerzen oft einen überspannten Körper haben und es ihnen schwerfällt, loszulassen. Deshalb ist es von großer Bedeutung, das Gleichgewicht zwischen Anspannen und Loslassen zu finden. " +
            "Unser Ziel ist es, dir zu zeigen, dass ein gesunder Rücken nicht nur von körperlicher Stärke, sondern auch von der Fähigkeit abhängt, loszulassen und zu entspannen. Finde die Balance zwischen Anspannen und Loslassen, um deinem Rücken eine optimale Unterstützung zu bieten und deinen Alltag mit Leichtigkeit zu meistern. " +
            "P.S. Videoqualität wird nach der ersten Minute besser. ",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_1.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834162030/rendition/720p/file.mp4?loc=external&signature=b4c985a0d594777cc270695923946d1e62da641585ea3b43ead4a798104e194b',
    'text': "Gesunde Hüfte, Starker Rücken: Der Joint-by-Joint Ansatz",
    'description':
        "Entdecke den Joint-by-Joint Ansatz und lerne, wie die Mobilität der Hüfte eine wichtige Rolle bei der Prävention von Rückenschmerzen spielt. In diesem Video tauchen wir in die faszinierende Welt der Gelenke ein und zeigen dir, wie du deine Hüfte mobilisieren kannst, um deinen Rücken zu stärken. " +
            "Der Joint-by-Joint Ansatz betont die unterschiedlichen Anforderungen an die Gelenke unseres Körpers. Insbesondere benötigt die Hüfte eine gute Mobilität, während die Lendenwirbelsäule (LWS) eher stabile Eigenschaften aufweisen sollte. Wenn die Hüftmobilität eingeschränkt ist, versucht die LWS diese Einschränkung zu kompensieren, indem sie sich übermäßig bewegt. Diese Überlastung kann zu Rückenschmerzen führen. " +
            "Bist du bereit, die Rolle deiner Hüfte bei der Prävention von Rückenschmerzen zu erkunden? Dann komm mit uns auf diese spannende Reise zur Mobilität und Stabilität. Lass uns deine Hüfte befreien und deinem Rücken eine solide Basis geben! ",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_2.jpg'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834164918/rendition/720p/file.mp4?loc=external&signature=45d1c93d42791c347b16796a68b2589f2afda2359c1be513a22d14be01c16499',
    'text':
        "Lösche den Brand statt die Batterie aus dem Rauchmelder zu ziehen.",
    'description':
        "Stell dir vor, dein Körper ist wie ein Haus und Rückenschmerzen sind wie ein schrillender Rauchmelder. Du könntest versucht sein, den Alarm einfach abzustellen, aber was ist mit der eigentlichen Ursache des Problems? " +
            "Wenn wir Schmerzen im Rücken verspüren, ist es wie der Alarm, der auf eine Verletzung oder ein anderes Problem hinweist. Es ist wichtig, den Schmerz nicht einfach zu ignorieren oder oberflächlich zu behandeln. Stell dir vor du schmierst eine Schmerzsalbe auf deinen Rücken oder nimmst einfach nur Schmerzmedikamente ein ohne die Hüfte oder deinen Schultergürtel zu untersuchen. Das wäre so, als würdest du die Batterie aus dem Rauchmelder entfernen, anstatt nach der eigentlichen Ursache des Alarms zu suchen. ",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834168208/rendition/720p/file.mp4?loc=external&signature=bd61c59014714c30bb3c76177d0f892a53aeff8945fabe137d8b630ae6eb4ced',
    'text': "Letztes Level Stufe 1",
    'description':
        "Herzlichen Glückwunsch! Du hast die erste Stufe der motorischen Entwicklung gemeistert und begibst dich nun in eine neue Phase. Es wird Zeit sich ein Stockwerk nach oben zu Bewegen und den Vierfüßlerstand zu meistern. " +
            "Während du dich auf diese neue Etappe vorbereitest, möchten wir dich ermutigen, das Gelernte anzuwenden und deine Fortschritte zu feiern. Deine Körperbeherrschung und motorischen Fähigkeiten werden immer besser. " +
            "Mach weiter so!",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834170796/rendition/720p/file.mp4?loc=external&signature=d01fd0500cd3594b0f3cb62aef6642f9d7ffbeb93d3e6f950827c8ffed9ab49a',
    'text': "Krabbeln für eine starke Core-Stabilität und Antirotation",
    'description': "In der Anfangsentspannung lernst du ab jetzt die gleichmäßige Bewegung des Zwerchfells (Bauchatmung) und des Brustkorbs." +
        "Danach kommst du aus dem Vierfüßlerstand ins Krabbeln." +
        "Sind Arm und Hand gleichzeitig in der Luft muss deine Rumpfmuskulatur arbeiten um dich stabil zu Halten." +
        "Dabei wird die Antirotation deiner Rumpfmuskulatur gekräftigt." +
        "Bereite dich darauf vor, deine Core-Muskulatur zu stärken und die Antirotation zu meistern! " +
        "Erfahre, wie das Krabbeln nicht nur deine koordinativen Fähigkeiten verbessert, sondern auch gezielt auf die Stärkung deiner Rumpfmuskulatur abzielt. " +
        "Tauche ein in eine Welt des dynamischen Zusammenspiels von Bauch- und Rückenmuskeln, um unerwünschte Rotationen zu verhindern und deine Core-Stabilität zu maximieren." +
        "Lass uns gemeinsam krabbeln und die Grundlage für eine gesunde und stabile Körperhaltung schaffen",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834694810/rendition/720p/file.mp4?loc=external&signature=50e709051251e35f284ba73d67c35d9a8547a7615dff76a69b72129ab794f76b',
    'text': "Höre auf deinen Körper!",
    'description': "Du mobilisierst deine Handgelenke, um sie beweglich und stark zu halten." +
        "Achte darauf die Schultern weg von den Ohren zu ziehen." +
        "Lasse deinen Atem auch in der Dehnung weiter fließen." +
        "Schmerz ist nur ein Signal deines Körpers und muss NICHT zwangsläufig auf eine Verletzung hinweisen. Deshalb wollen wir dir helfen, dieses Signal zu verstehen und die richtigen Maßnahmen zu ergreifen." +
        "Schmerz kann auch ein Weg deines Körpers sein dir mitzuteilen, dass der umliegende Bereich verspannt ist und nach mehr Bewegung ruft." +
        "Denke immer daran: Schmerz ist nicht dein Feind ist, sondern ein Wegweiser zu einem gesünderen und beweglicheren Körper." +
        "Mit den richtigen Mobilisationsübungen kannst du deine Rückenschmerzen reduzieren und dich wieder frei und energiegeladen fühlen." +
        "Also, worauf wartest du? Klicke jetzt auf Play und entdecke die transformative Kraft der Mobilisationsübungen!",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834697298/rendition/720p/file.mp4?loc=external&signature=7a038d31756b419cd3322d5fabee05f186cf77787a62f045b7a41d8f527c9c10',
    'text':
        "Die Geheimnisse des Körper-Zusammenspiels enthüllt: Das Regional Interdependence Model",
    'description': "Du arbeitest an der Beweglichkeit deiner Hüfte und Brustwirbelsäule (BWS). " +
        "Beide sind nach dem Regional Interdependence Modell von großer Bedeutung bei der Prävention von Rückenschmerzen. " +
        "Achte beim Einzelellbogenstütz (3. Übung) darauf den Bauchnabel zur Wirbelsäule zu ziehen, um den unteren Rücken zu entlasten." +
        "Hey du! Bist du es leid, immer nur Symptome zu behandeln, ohne die eigentliche Ursache deiner Schmerzen zu finden? Dann haben wir etwas Aufregendes für dich! " +
        "Schluss mit der traditionellen Herangehensweise, bei der nur der schmerzende Bereich behandelt wird! " +
        "Die Lösung kann möglicherweise in einer ganz anderen Region deines Körpers liegen. Klingt verrückt, oder? Aber es ist wahr!" +
        "Lass uns ein Beispiel geben: Hast du schon einmal Schmerzen im unteren Rücken gehabt? " +
        "Nun, nach dem Regional Interdependence Model könnten die eigentlichen Probleme in deiner Hüfte, der Brustwirbelsäule oder im Schultergürtel liegen. " +
        "Unglaublich, oder? Dein Körper ist ein Meister der Kompensation, und manchmal versucht er, Dysfunktionen in anderen Bereichen auszugleichen, was dann zu Schmerzen an unerwarteten Stellen führt." +
        "Alle Videos zielen darauf ab, nicht nur die Symptome zu lindern, sondern auch die zugrunde liegenden Ursachen anzugehen. " +
        "Mit gezielten Bewegungs- und Stabilisationsübungen und Entspannungstechniken wirst du den Körper-Zusammenhang auf eine ganz neue Art und Weise erleben." +
        "Also, schnapp dir deinen Lieblingsplatz, drück auf Play und lass uns gemeinsam die faszinierende Welt des Körper-Zusammenspiels erkunden! " +
        "Befreie dich von den Fesseln der traditionellen Behandlungsansätze und entdecke das Regional Interdependence Model für dich selbst.",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834174282/rendition/720p/file.mp4?loc=external&signature=76a45c181958e2952e4ed4e308c3eb3330384d6651e01f8825290af73521a129',
    'text': "Starke Handgelenke: Die Geheimwaffe gegen Verletzungen",
    'description': "Du setzt wieder den Fokus auf die Handgelenke." +
        "Erst kräftigend mit der Hüftdrehung im Bärenhalt – lerne dich auf einer Hand zu stabilisieren!" +
        "Danach mobilisierst du deine Handgelenke – achte darauf die Schultern weg von den Ohren fallen zu lassen!" +
        "Bist du bereit, deine Handgelenke zu stärken und Verletzungen vorzubeugen? " +
        "Tauche ein in die faszinierende Welt der Handgelenksgesundheit und entdecke die Vorteile der Handgelenksgymnastik. Wir zeigen dir, wie du Flexibilität, Stabilität und Kraft deiner Handgelenke verbessern kannst. " +
        "Gemeinsam stärken wir die Muskulatur rund um die Handgelenke und sorgen für eine bessere Durchblutung, um Nährstoffe effizienter zu transportieren und Verletzungsrisiken zu minimieren." +
        "Erfahre, wie Handgelenksgymnastik Überlastungsschäden vorbeugen kann, insbesondere für diejenigen, die häufig am Computer arbeiten oder repetitive Handbewegungen ausführen." +
        "Dann komm mit uns auf diese spannende Reise und mach dich bereit für starke und gesunde Handgelenke!",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834178314/rendition/720p/file.mp4?loc=external&signature=4b1cd078f73715c70aef6738fa0a1f1e2ad63800490a752fd632d80e1cb24e27',
    'text': "Starke Schulterblätter für eine kraftvolle und gesunde Schulter",
    'description': "Du setzt den Fokus auf die Bewegung deiner Schulterblätter." +
        "Im PushUp+ lernst du deine Schulterblätter aktiv anzusteuern." +
        "Das gelernte überträgst du dann im Herabschauenden Hund in eine andere Bewegungsebene." +
        "Ein starkes Schulterblatt ist der Schlüssel zu einer leistungsfähigen und verletzungsfreien Schulter." +
        "Entdecke effektive Übungen und Techniken, um deine Schulterblattmuskulatur zu stärken und die optimale Ausrichtung des Arms zu erreichen. " +
        "Erfahre, wie du unerwünschte Kompensationsbewegungen vermeidest und die Belastung auf Muskeln und Sehnen reduzierst. " +
        "Mit einer starken und funktionalen Schulterblattmuskulatur bist du bereit, deine sportlichen Ziele zu erreichen und Verletzungen vorzubeugen. " +
        "Bist du bereit, dein Schulterblatt auf das nächste Level zu bringen?",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834182013/rendition/720p/file.mp4?loc=external&signature=d48b455115b96f5456c69fa739379bea2d6f635e7944caa9e57b9743ee233a4b',
    'text': "Die versteckte Verbindung unser Füße zu Rückenschmerzen",
    'description': "Du lernst deine Hüfte besser anzusteuern und zu stabilisieren." +
        "Anschließend arbeitest du an der Mobilität und Kraft deiner Füße." +
        "Besonders deiner Plantarfaszie – auf den Unterseiten der Füße." +
        "Die haben nach dem Regional Interdepenence Modell einen direkten Einfluss auf Rückenschmerzen." +
        "Entdecke die versteckte Verbindung zwischen der hinteren Kette deines Körpers und der Plantarfaszie in deinen Füßen für einen starken und schmerzfreien Rücken." +
        "Erfahre mehr über die Auswirkungen einer verhärteten oder verkürzten Plantarfaszie auf die gesamte hintere Kette und wie dies zu Rückenschmerzen führen kann. " +
        "Lerne gezielte Übungen und Mobilisationstechniken kennen, um deine Körperhaltung zu verbessern, die Flexibilität zu steigern und Rückenschmerzen zu reduzieren." +
        "Lerne mehr über effektive Strategien, um deine Wirbelsäule zu entlasten!",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834185765/rendition/720p/file.mp4?loc=external&signature=a3782acb43f626a0230536755a0dd0991c05ffba28dbdef057b7920b1c8ed351',
    'text': "Warum gibt es so wenig statisches Dehnen in den Videos?",
    'description': "Du arbeitest im Seitsitz an der Mobilität deiner Hüfte." +
        "Achte auf langsame und gleichmäßige Bewgeungen." +
        "Anschließend noch an der Mobilität und Stabilität im Schultergürtel mit dem Herabschauenden Hund." +
        "Schiebe dabei dein Gesäß zur Decke und den Brustkorb zu den Knien." +
        "Entfessle deine Beweglichkeit - Das Geheimnis der Mobility! " +
        "Willst du deinen Körper in vollem Umfang bewegen können? Möchtest du deine Beweglichkeit verbessern und gleichzeitig stabil und kontrolliert agieren? Dann ist es Zeit für Mobility!" +
        "Mobility ist mehr als nur einfaches Dehnen. Kurz gesagt ist Mobility= Flexibilität (passiv) + motorische Kontrolle (aktiv) + Kraft. " +
        "Es ist ein aktiver Ansatz, der es dir ermöglicht, Bewegungseinschränkungen zu identifizieren und zu überwinden. Gemeinsam werden wir gezielte Mobilisationsübungen durchführen, die deine Gelenke und umliegenden Strukturen auf sanfte und doch effektive Weise mobilisieren. " +
        "Du wirst spüren, wie deine Beweglichkeit Schritt für Schritt zunimmt und du deinen Körper in vollen Zügen genießen kannst." +
        "Der große Vorteil von Mobility gegenüber statischem Dehnen liegt in der Nachhaltigkeit und Übertragbarkeit auf den Sport. Du wirst nicht nur flexibler, sondern auch stabiler und kontrollierter in deinen Bewegungen. " +
        "Dein Nervensystem wird aktiviert und deine sensorische Wahrnehmung geschult, so dass du eine bessere Körperkontrolle entwickelst und Verletzungsrisiken minimierst.",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834189198/rendition/720p/file.mp4?loc=external&signature=5c6a59cd918e123538058e8d7e81f59b976f2b5acc76594a27f4e5a4a360704f',
    'text': "Die Landkarten der Bewegung",
    'description': "Nun wechselt du im Seitsitz die Positionen – leite die Bewegung aus dem Knie zuerst ein." +
        "Denke daran den Atem weiter fließen zu lassen." +
        "Beim Aufrotieren der Brustwirbelsäule folgt dein Blick der Hand durch die ganze Bewegung." +
        "Schon seit unseren Kindesbeinen speichert unser Gehirn alle Bewegungsmuster. Ob Krabbeln, gehen oder greifen. " +
        "Das Ganze können wir uns vorstellen wie Straßen. Wird eine Bewegung nur ein paar Mal ausgeführt entsteht ein Trampelpfad durch eine dicht bewachsene Wiese. ",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834192567/rendition/720p/file.mp4?loc=external&signature=adb2f230f7c11b513fd96d5a86e48308aeebf7dfdd6f89279b3b299344a1d1e0',
    'text': "Die einzig „richtige“ Sitzposition ist immer die nächste!",
    'description': "Im Toten Käfer (Übung 2) kräftigst du deine Rumpfmusukaltur – ziehe dabei den Bauchnabel zur Wirbelsäule." +
        "Anschließend lockerst du dich beim Baby Rolling (Übung 3) – achte darauf die Beine locker zu lassen!" +
        "Nach eine Vorbereitung der Handgelenke kräftigst du deine einarmige Stützkraft." +
        "Lange wurde erzählt, dass wir immer in einer perfekt gerade Körperhaltung sitzen, müssten um Rückenschmerzen vorzubeugen. " +
        "In neueren Forschungen zeigt sich aber, dass unsere Körperhaltung einen viel kleineren Einfluss auf Schmerzen hat als bisher angenommen." +
        "Der menschliche Körper ist für Bewegung gemacht - er sehnt sich nach Veränderung und Variation. Wenn wir lange Stunden in einer starren Sitzposition verharren, fühlen sich unsere Muskeln und Gelenke eingeschränkt und steif an. " +
        "Unser Körper schreit förmlich nach Bewegung, um die Spannung zu lösen und die Durchblutung zu fördern. " +
        "Die Lösung liegt in der Vielfalt und Bewegung! Indem wir regelmäßig unsere Sitzposition verändern, aufstehen, uns dehnen und kleine Bewegungspausen einlegen, geben wir unserem Körper genau das, was er braucht - Abwechslung und Entlastung. " +
        "Unser Körper wird es uns danken, indem er geschmeidiger und flexibler wird. " +
        "Bereit, deinen Körper zu befreien und ihm die Variation zu geben, nach der er sich sehnt? " +
        "Dann schnapp dir deinen Stuhl, finde bequeme Kleidung und lass uns gemeinsam einen Schritt in Richtung eines bewegten und schmerzfreien Lebens machen.",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
  {
    'path':
        'https://player.vimeo.com/progressive_redirect/playback/834195887/rendition/720p/file.mp4?loc=external&signature=fbe59575c124e4b9a00e49619e82925656ae1478912e7d2c0423bb4562f39787',
    'text': "2_10",
    'description': "Du hast die zweite Stufe nun so gut wie geschafft." +
        "Der Fokus liegt nochmal auf der Bewegung deiner Schulterblätter und der Stabilität im Schultergürtel." +
        "Zum Abschluss mobilisierst du noch deine Brustwirbelsäule (BWS) – der Blick folgt deinem Ellbogen in der ganzen Bewegung." +
        "Herzlichen Glückwunsch!" +
        "Du hast erfolgreich das Ende der ersten Testversion erreicht und ich möchte dir meinen aufrichtigen Glückwunsch aussprechen! Du hast kontinuierlich an deiner Rückenschmerzprävention gearbeitet und bist auf dem richtigen Weg zu einem gesunden und schmerzfreien Rücken." +
        "Während dieser ersten Etappe hast du wertvolles Wissen über deinen Körper und verschiedene Übungen erlangt. Du hast gelernt, wie wichtig es ist, deinem Rücken regelmäßig Aufmerksamkeit zu schenken und ihn durch gezielte Übungen zu stärken. Dein Engagement und deine Ausdauer sind bewundernswert, und ich bin stolz darauf, dass du bis hierhin gekommen bist." +
        "Aber das ist erst der Anfang! In den kommenden Wochen werden wir nach und nach neue Trainings-, Wissens- und Entspannungsinhalte einführen, um deine Rückenschmerzprävention noch effektiver und abwechslungsreicher zu gestalten. Du darfst dich auf spannende und neue Herausforderungen freuen, die dich dabei unterstützen, deinen Rücken weiter zu stärken und deine Flexibilität zu verbessern. " +
        "Aber wir hören nicht nur bei den Inhalten auf. Wir möchten deine Erfahrung mit unserer App kontinuierlich verbessern und auf deine Bedürfnisse eingehen. Daher freuen wir uns immer über dein Feedback! Teile uns mit, wie dir die bisherigen Übungen, Wissenstexte und Entspannungsinhalte gefallen haben. Lass uns wissen, welche neuen Features du dir wünschst und wie wir deine Trainingsroutine noch besser gestalten können." +
        "Vielen Dank im Voraus! Mit deiner Hilfe können wir gemeinsam etwas besonderes erschaffen! ",
    'overlay': Thumbnail('assets/thumbnails/level_3/3_3.png'),
  },
];

List<Map<String, dynamic>> _levelList = [
  {
    'id': 1,
    'title': 'Level 1',
    'description': Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoPlayerView(
          path: _videoList[0]['path'],
          text: _videoList[0]['text'],
          description: _videoList[0]['description'],
          overlay: _videoList[0]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[1]['path'],
          text: _videoList[1]['text'],
          description: _videoList[1]['description'],
          overlay: _videoList[1]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[2]['path'],
          text: _videoList[2]['text'],
          description: _videoList[2]['description'],
          overlay: _videoList[2]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[3]['path'],
          text: _videoList[3]['text'],
          description: _videoList[3]['description'],
          overlay: _videoList[3]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[4]['path'],
          text: _videoList[4]['text'],
          description: _videoList[4]['description'],
          overlay: _videoList[4]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[5]['path'],
          text: _videoList[5]['text'],
          description: _videoList[5]['description'],
          overlay: _videoList[5]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[6]['path'],
          text: _videoList[6]['text'],
          description: _videoList[6]['description'],
          overlay: _videoList[6]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[7]['path'],
          text: _videoList[7]['text'],
          description: _videoList[7]['description'],
          overlay: _videoList[7]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[8]['path'],
          text: _videoList[8]['text'],
          description: _videoList[8]['description'],
          overlay: _videoList[8]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[9]['path'],
          text: _videoList[9]['text'],
          description: _videoList[9]['description'],
          overlay: _videoList[9]['overlay'],
        ),
      ],
    ),
    'isExpanded': false,
    'isPlayed': false
  },
  {
    'id': 2,
    'title': 'Level 2',
    'description': Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoPlayerView(
          path: _videoList[10]['path'],
          text: _videoList[10]['text'],
          description: _videoList[10]['description'],
          overlay: _videoList[10]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[11]['path'],
          text: _videoList[11]['text'],
          description: _videoList[11]['description'],
          overlay: _videoList[11]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[12]['path'],
          text: _videoList[12]['text'],
          description: _videoList[12]['description'],
          overlay: _videoList[12]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[13]['path'],
          text: _videoList[13]['text'],
          description: _videoList[13]['description'],
          overlay: _videoList[13]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[14]['path'],
          text: _videoList[14]['text'],
          description: _videoList[14]['description'],
          overlay: _videoList[14]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[15]['path'],
          text: _videoList[15]['text'],
          description: _videoList[15]['description'],
          overlay: _videoList[15]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[16]['path'],
          text: _videoList[16]['text'],
          description: _videoList[16]['description'],
          overlay: _videoList[16]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[17]['path'],
          text: _videoList[17]['text'],
          description: _videoList[17]['description'],
          overlay: _videoList[17]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[18]['path'],
          text: _videoList[18]['text'],
          description: _videoList[18]['description'],
          overlay: _videoList[18]['overlay'],
        ),
        VideoPlayerView(
          path: _videoList[19]['path'],
          text: _videoList[19]['text'],
          description: _videoList[19]['description'],
          overlay: _videoList[19]['overlay'],
        ),
      ],
    ),
    'isExpanded': false,
    'isPlayed': false
  }
];

getVideoList() {
  return _videoList;
}

class Levels extends StatefulWidget {
  const Levels({Key? key}) : super(key: key);

  @override
  _LevelsState createState() => _LevelsState();
}

class _LevelsState extends State<Levels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          elevation: 3,
          // Controlling the expansion behavior
          expansionCallback: (index, isExpanded) {
            setState(() {
              _levelList[index]['isExpanded'] = !isExpanded;
            });
          },
          animationDuration: Duration(milliseconds: 600),
          children: _levelList
              .map(
                (item) => ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: Colors.white,
                  headerBuilder: (_, isExpanded) => Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      child: Text(
                        item['title'],
                        style: TextStyle(fontSize: 20),
                      )),
                  body: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    child: item['description'],
                  ),
                  isExpanded: item['isExpanded'],
                ),
              )
              .toList(),
        ),
      ),
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
    required this.overlay,
  }) : super(key: key);

  final int? order;
  final String path;
  final String text;
  final String description;
  final Widget overlay;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    setState(() {});

    userId = await getUserId();

    videoPlayerController!.addListener(videoProgressListener);
  }

  void updateLevel() async {
    int increasedOrder = widget.order! + 1;
    String levelField = 'level${increasedOrder}';
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

  void videoProgressListener() {
    if (chewieController != null) {
      final position = chewieController!.videoPlayerController.value.position;
      final duration = chewieController!.videoPlayerController.value.duration;

      if (position >= duration * 0.5) {
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
    if (isClicked == false) {
      return Column(
        children: [
          Container(
            height: 200,
            width: 800,
            margin: const EdgeInsets.symmetric(vertical: 50.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 153, 152, 152),
              border: Border.all(
                width: 2,
                color: Color.fromARGB(255, 153, 152, 152),
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
          VideoText(widget.text, widget.description),
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
          VideoText(widget.text, widget.description),
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
            color: Color.fromARGB(255, 153, 152, 152),
            border: Border.all(
              width: 2,
              color: Color.fromARGB(255, 153, 152, 152),
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Chewie(
            controller: chewieController!,
          ),
        ),
        VideoText(widget.text, widget.description),
      ],
    );
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }
}

class VideoText extends StatefulWidget {
  VideoText(this.text, this.description);

  final String text;
  final String description;

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
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
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
            decoration: BoxDecoration(
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
                      showDescription
                          ? 'Close Description'
                          : 'Open Description',
                      style: const TextStyle(
                        fontSize: 16,
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
                if (showDescription)
                  Container(
                    constraints: BoxConstraints(maxHeight: 250),
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Thumbnail extends StatelessWidget {
  Thumbnail(this.path);

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
    required this.description,
    required this.overlay,
  }) : super(key: key);

  final int? order;
  final String path;
  final String text;
  final String description;
  final Widget overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(text),
      ),
      body: Column(
        children: [
          Center(
            child: VideoPlayerView(
              order: order,
              path: path,
              text: "",
              description: description,
              overlay: overlay,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
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
                        title: Text(
                          "Level Abgeschlossen",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        description: Text(
                          "qweqweqweqweqwe",
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
                          "assets/not.png",
                          fit: BoxFit.fitWidth,
                          width: 90,
                        ),
                        title: Text(
                          "Level Nicht geschafft",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        description: Text(
                          "qweqweqweqweqwe",
                          textAlign: TextAlign.center,
                          style: TextStyle(),
                        ),
                        entryAnimation: EntryAnimation.top,
                        onOkButtonPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
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
      ),
    );
  }
}
