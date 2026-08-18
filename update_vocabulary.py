import json
import os

# Ruta del archivo
file_path = r"c:\Users\alexa\Desktop\easyenglish\assets\data\vocabulary.json"

# Leer el archivo
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Encontrar la categoría "phrases"
phrases_category = None
for cat in data['categories']:
    if cat['id'] == 'phrases':
        phrases_category = cat
        break

if not phrases_category:
    print("ERROR: No se encontró la categoría 'phrases'")
    exit(1)

# Contadores
cards_updated = 0
last_card_id = None

# Diccionario con extraExamples para cada tarjeta p_21 a p_100
extra_examples_map = {
    "p_21": [
        "Excuse me, does this bus go to the city center?",
        "Excuse me — I think you dropped your wallet back there.",
        "Excuse me, could you tell me how to get to the nearest subway station?"
    ],
    "p_22": [
        "Good morning everyone! I'm sorry for being late — the subway was delayed.",
        "I'm sorry for being late again, I got stuck in really bad traffic.",
        "I'm sorry for being late, my alarm didn't go off this morning."
    ],
    "p_23": [
        "Thanks for waiting for me! — No problem at all, I just got here.",
        "I hope I didn't cause any inconvenience. — No problem at all!",
        "No problem at all — I was happy to help you move your furniture."
    ],
    "p_24": [
        "Hey Carlos! Long time no see — we should catch up over coffee!",
        "Long time no see! How have you been? I've missed our chats.",
        "Wow, long time no see! You look great — have you been working out?"
    ],
    "p_25": [
        "Hey Sarah! What's up? I haven't seen you since the party last weekend.",
        "What's up with you lately? You seem really busy at work.",
        "Hey man, what's up? Wanna grab some pizza and watch the game tonight?"
    ],
    "p_26": [
        "How have you been feeling? — I'm fine, thank you, just a little tired.",
        "I heard you had a tough week — are you okay? I'm fine, thank you!",
        "I'm fine, thank you for asking! How about you, how's your family doing?"
    ],
    "p_27": [
        "Could you speak slower? I'm still learning English and want to understand everything.",
        "Sorry, could you speak slower? The connection on this call is not very good.",
        "Could you speak slower, please? I want to write down your phone number correctly."
    ],
    "p_28": [
        "I saw this sign on the street — what does this mean exactly?",
        "What does this mean in context? I've heard people say it but I'm not sure.",
        "Sorry, what does this mean? I don't recognize this word at all."
    ],
    "p_29": [
        "How do you pronounce this? Is it with a hard or soft 'th' sound?",
        "I want to introduce myself properly — how do you pronounce this name?",
        "Excuse me, how do you pronounce this word? I've only read it in books."
    ],
    "p_30": [
        "Can I help you find anything specific? — No thanks, I'm just looking around.",
        "The employee asked if I needed help, but I told him I'm just looking.",
        "I'm not buying anything today — I'm just looking to see what's new."
    ],
    "p_31": [
        "Waiter, when you get a chance, can I have the check, please?",
        "That was delicious — can I have the check, please? We need to catch a train.",
        "Excuse me, can I have the check, please? And could you wrap up the leftovers too?"
    ],
    "p_32": [
        "Where can I find a good place to eat around here? I'm visiting from out of town.",
        "Excuse me — where can I find the entrance to the museum?",
        "Where can I find bottled water and snacks? I'm going on a road trip."
    ],
    "p_33": [
        "Good evening, I would like to order the seafood pasta and a glass of white wine.",
        "I would like to order a large pepperoni pizza for delivery, please.",
        "Before we start, I would like to order some appetizers for the whole table."
    ],
    "p_34": [
        "Here's thirty dollars for the twenty dollar meal — keep the change!",
        "You don't have to give me back the two dollars — keep the change.",
        "The taxi fare was $18.50 so I handed him $20 and said keep the change."
    ],
    "p_35": [
        "I can't stop to chat right now — I'm in a hurry to catch my flight!",
        "I'm in a hurry, could you recommend the fastest route to the highway?",
        "Sorry I can't stay longer, I'm in a hurry to pick up my kid from school."
    ],
    "p_36": [
        "Let me know if you change your mind about coming to the concert this Saturday.",
        "Let me know when you're done with the report so I can review it.",
        "Let me know what time works best for you and I'll schedule the meeting."
    ],
    "p_37": [
        "Should we watch a movie or go for a walk instead? — It's up to you!",
        "It's up to you whether we eat Mexican or Italian tonight — I love both!",
        "I'm flexible with the travel dates — it's up to you and your work schedule."
    ],
    "p_38": [
        "I'm not sure if I should accept the job offer or wait for something better.",
        "Are you going to the party? — I'm not sure yet, I might have to work late.",
        "I'm not sure how to use this new app, could you show me how it works?"
    ],
    "p_39": [
        "How does spending the weekend at the beach sound? — That sounds great!",
        "I found this new coffee shop nearby, want to check it out? That sounds great!",
        "That sounds great! I've been wanting to try sushi for the longest time."
    ],
    "p_40": [
        "Good luck with your piano recital tonight — I know you'll do amazing!",
        "Good luck on your first day at the new job! You're going to kill it.",
        "Good luck with the exam tomorrow! You've studied so hard for this."
    ],
    "p_41": [
        "Congratulations on getting promoted! You really deserve this opportunity.",
        "Congratulations on your wedding day! I wish you both a lifetime of happiness.",
        "Congratulations! I heard you just bought your first house — that's so exciting!"
    ],
    "p_42": [
        "You finished the marathon! I'm so proud of you for never giving up.",
        "I'm proud of you for standing up for what you believe in, even when it's hard.",
        "Your little sister won the spelling bee — I'm proud of you both!"
    ],
    "p_43": [
        "I'm so sorry I scratched your bike. — Don't worry about it, it was old anyway.",
        "Don't worry about it — accidents happen and it's not that big of a deal.",
        "I think I forgot to send that email yesterday. — Don't worry about it, just send it today."
    ],
    "p_44": [
        "By the way, I ran into your sister at the grocery store yesterday!",
        "We should finalize the travel plans soon. Oh, and by the way, have you renewed your passport?",
        "It was great seeing you! By the way, your new haircut looks amazing on you."
    ],
    "p_45": [
        "To be honest, I didn't really enjoy the movie that much — the plot was confusing.",
        "To be honest with you, I think we should look for a different solution to this problem.",
        "I know you asked for my opinion, so to be honest, I don't think that color suits you."
    ],
    "p_46": [
        "In my opinion, learning a second language is one of the best investments you can make.",
        "In my opinion, this restaurant has the best pizza in the entire city.",
        "Well, in my opinion, we should postpone the trip until the weather improves."
    ],
    "p_47": [
        "I'm looking forward to it — I've wanted to visit Japan since I was a kid!",
        "The conference is next week and I'm looking forward to it so much.",
        "We're having dinner at your parents' on Sunday — I'm really looking forward to it!"
    ],
    "p_48": [
        "Are you ready? The taxi is already waiting outside for us.",
        "Are you ready to order yet, or do you need a few more minutes with the menu?",
        "It's almost time for the presentation to start — are you ready?"
    ],
    "p_49": [
        "Okay everyone, let's get started — we have a lot to cover in today's meeting.",
        "Let's get started! First on the agenda is the quarterly budget review.",
        "Welcome to cooking class! Let's get started by prepping the vegetables."
    ],
    "p_50": [
        "Wait here at the table, I'll be right back with our drinks.",
        "I'll be right back — I just need to run to the restroom quickly.",
        "Don't go anywhere! I'll be right back with the car keys."
    ],
    "p_51": [
        "Take your time filling out the forms — there's no deadline for this.",
        "You can take your time deciding which one to buy — I'll wait over here.",
        "Take your time with the meal, we're not in any rush at all."
    ],
    "p_52": [
        "You're crying! What happened? Did someone hurt you?",
        "What happened to your arm? Did you fall off your bike again?",
        "The whole office is whispering — what happened while I was at lunch?"
    ],
    "p_53": [
        "Are you kidding me? I've been waiting in this line for over an hour!",
        "You paid $500 for those shoes? Are you kidding me?",
        "Are you kidding me? I can't believe they canceled the concert at the last minute!"
    ],
    "p_54": [
        "That's awesome! You're going to be working in the same office as your best friend.",
        "You got front row tickets to the concert? That's awesome!",
        "That's awesome news! Congratulations on the new baby — when is she due?"
    ],
    "p_55": [
        "I can't believe it — we actually won the lottery ticket we bought on a whim!",
        "I can't believe it, you learned to play the guitar in just two months?",
        "I can't believe it's already been a year since we graduated from college!"
    ],
    "p_56": [
        "Have fun at your birthday party! I wish I could be there to celebrate with you.",
        "Have fun on your date tonight! Let me know how it goes tomorrow.",
        "Have fun hiking this weekend — watch out for bears and take lots of photos!"
    ],
    "p_57": [
        "Safe travels! Text me when you land safely so I know you're okay.",
        "Safe travels to Europe! I can't wait to see all your Instagram photos.",
        "Safe travels on your road trip! Drive carefully and stop to rest when you're tired."
    ],
    "p_58": [
        "Feel better soon! I'll drop off some soup and medicine at your place later.",
        "I heard you caught a cold — feel better soon and get plenty of rest!",
        "Feel better soon! The team misses you at work and we can't wait for you to come back."
    ],
    "p_59": [
        "You and Mike are finally engaged? I'm so glad to hear that — congratulations!",
        "I'm so glad to hear that the surgery went well and your mom is recovering quickly.",
        "I'm so glad to hear that you got the promotion! You've worked so hard for it."
    ],
    "p_60": [
        "Is this shirt available in medium? Let me check the stockroom for you.",
        "Let me check if I have any cash in my wallet before we go to the cash-only restaurant.",
        "Let me check my calendar first, then I'll get back to you about that meeting."
    ],
    "p_61": [
        "I love the design of this dress — can I try this on in a size small?",
        "Excuse me, can I try this on? Where are your fitting rooms located?",
        "These shoes look really nice — can I try this on with my jeans?"
    ],
    "p_62": [
        "Where is the fitting room? I'd like to try on a couple of these shirts.",
        "Excuse me, could you tell me where is the fitting room in this department?",
        "I can't find where to try these clothes on — where is the fitting room?"
    ],
    "p_63": [
        "Do you accept credit cards, or is this establishment cash-only?",
        "Before I order anything, do you accept credit cards here? I don't have any cash on me.",
        "I was about to pay, then realized I forgot my wallet — do you accept credit cards or mobile pay?"
    ],
    "p_64": [
        "Can you help me, please? I'm lost and my phone has no GPS signal.",
        "I'm lost — could you tell me which direction the main train station is?",
        "I think I'm lost. I'm trying to get back to my hotel on 5th Avenue."
    ],
    "p_65": [
        "He's not breathing! Someone call an ambulance immediately!",
        "There's been a car accident on the corner — call an ambulance right now!",
        "Call an ambulance! I think my grandfather is having a heart attack!"
    ],
    "p_66": [
        "You've been on the phone looking really worried — is everything okay?",
        "Is everything okay at home? You seem really distracted during class today.",
        "I heard there was an earthquake near your hometown — is everything okay with your family?"
    ],
    "p_67": [
        "You've been studying Spanish for only three months? That's impressive — this test will be a piece of cake for you.",
        "Don't stress about assembling the furniture — it comes with instructions and it's a piece of cake.",
        "I thought the math exam would be hard, but honestly it was a piece of cake!"
    ],
    "p_68": [
        "I know you missed the beginning of the movie, but better late than never!",
        "You're two hours late to the party! But hey, better late than never — grab a drink!",
        "Better late than never! I'm just glad you could make it to the wedding after all."
    ],
    "p_69": [
        "How's your new job going two weeks in? — So far, so good! Everyone on the team is really nice.",
        "We're halfway through the renovation. So far, so good — no major surprises yet.",
        "How's the new diet working out? So far, so good! I've already lost three pounds."
    ],
    "p_70": [
        "It feels like yesterday we were freshman in college — time flies when you're having fun!",
        "Time flies! I can't believe my baby is already starting kindergarten next week.",
        "Wow, time flies! We've been married for twenty-five years already."
    ],
    "p_71": [
        "You're going to be amazing in the play tonight — break a leg!",
        "Break a leg at your talent show audition! I know you can wow the judges.",
        "Break a leg on your presentation today! You've practiced it so many times."
    ],
    "p_72": [
        "I've been taking care of three sick kids all week — I'm exhausted!",
        "I'm exhausted after that 10K run this morning. I think I need a nap.",
        "Let's not go out tonight — I worked a 12-hour shift and I'm absolutely exhausted."
    ],
    "p_73": [
        "We haven't eaten since breakfast and it's already 4 PM — I'm starving!",
        "I'm starving! Is there anywhere we can grab a quick bite to eat around here?",
        "I'm so starving I could eat an entire pizza by myself right now."
    ],
    "p_74": [
        "Bundle up warm before you go out — it's freezing outside and the wind is brutal!",
        "It's freezing outside! I could see my breath the moment I stepped out the door.",
        "Don't forget your gloves and scarf — it's freezing outside this morning."
    ],
    "p_75": [
        "It's boiling hot in this room — can someone please turn on the air conditioner?",
        "It's boiling hot today! Let's go to the swimming pool to cool off instead of the park.",
        "I don't know how you can walk in this heat — it's boiling hot outside!"
    ],
    "p_76": [
        "What a relief! I thought I'd lost my passport, but it was in my other bag the whole time.",
        "The doctor said all the tests came back normal — what a relief!",
        "What a relief the storm passed without causing any damage to our neighborhood."
    ],
    "p_77": [
        "Now that you're moving to a different city, promise we'll keep in touch!",
        "It was so great catching up with you — keep in touch, okay?",
        "Here's my new email and phone number — let's definitely keep in touch!"
    ],
    "p_78": [
        "Don't order dinner without me! I'm on my way — stuck in traffic though.",
        "I just left the office, I'm on my way to the restaurant now.",
        "I'm on my way! I should be at your place in about 15 minutes."
    ],
    "p_79": [
        "There are police cars and fire trucks everywhere on our street — what's going on?",
        "What's going on? Why is everyone looking up at the sky like that?",
        "I heard shouting from the apartment upstairs — do you know what's going on?"
    ],
    "p_80": [
        "Would you mind if we listened to something else on the radio? — I don't mind at all.",
        "I don't mind where we eat tonight — you can pick wherever you like.",
        "You can borrow my car if you need it — I don't mind, just bring it back with a full tank."
    ],
    "p_81": [
        "I can't talk right now — I'm about to walk into a meeting. Call me later, okay?",
        "Call me later when you're free, I want to tell you all about my crazy day!",
        "I'm super busy with homework at the moment, can you call me later tonight?"
    ],
    "p_82": [
        "Hey, let's hang out next weekend! We could go bowling or catch a movie.",
        "Let's hang out sometime soon! I miss our random late-night conversations.",
        "Now that we live in the same city, we should let's hang out way more often."
    ],
    "p_83": [
        "I know the competition is going to be tough, but I'll do my best!",
        "I'm not sure if I can fix your laptop, but I'll do my best to figure it out.",
        "I'll do my best to finish the project by Friday, even if I have to work overtime."
    ],
    "p_84": [
        "Learning to play the guitar is really frustrating right now — but don't give up!",
        "Don't give up on your dreams just because things are difficult right now.",
        "I know you're tired of failing, but please don't give up — you'll get there!"
    ],
    "p_85": [
        "I know the interview seems scary, but you can do it! You're more than qualified.",
        "You've been practicing for months — you can do it! Go out there and show them what you've got.",
        "It's a challenging hike to the top, but you can do it! The view at the summit is worth it."
    ],
    "p_86": [
        "You couldn't get tickets to the sold-out show? That's too bad — I was really looking forward to going with you.",
        "That's too bad about your flight being canceled. Did they book you on another one?",
        "That's too bad your favorite restaurant closed down. Let's find a new one to try together!"
    ],
    "p_87": [
        "Thanks so much for walking my dog while I was out of town — I really appreciate it.",
        "I appreciate it! You didn't have to go out of your way to help me move all these boxes.",
        "I appreciate it more than you know — thanks for listening to me vent about work."
    ],
    "p_88": [
        "Take a sweater with you just in case the restaurant is cold inside.",
        "I always keep a portable charger in my bag, just in case my phone dies.",
        "Just in case you didn't hear, the meeting got rescheduled to tomorrow afternoon."
    ],
    "p_89": [
        "Speak of the devil! We were just talking about you and your upcoming vacation.",
        "Well, speak of the devil — here's the pizza delivery guy right now!",
        "Speak of the devil! We were just discussing whether you'd come to the party or not."
    ],
    "p_90": [
        "Long story short, we missed our flight because the taxi got stuck in traffic for two hours.",
        "Long story short — she said yes to marrying me!",
        "I could explain all the technical details, but long story short, the project was a huge success."
    ],
    "p_91": [
        "Keep your fingers crossed for me! I submitted my application to my dream university today.",
        "I'm waiting to hear back about the promotion — keep your fingers crossed!",
        "Keep your fingers crossed that the weather stays nice for our outdoor wedding this weekend."
    ],
    "p_92": [
        "Sorry, I didn't catch that — could you please tell me your name again?",
        "The microphone at the back isn't working well. I didn't catch that last part, could you repeat it?",
        "I didn't catch that — there was so much background noise at the coffee shop."
    ],
    "p_93": [
        "Point taken — you're right that we should have double-checked the numbers before sending the report.",
        "Point taken. I'll make sure to leave earlier for meetings from now on so I'm not late.",
        "Okay, point taken — I won't bring up that sensitive topic at the dinner table again."
    ],
    "p_94": [
        "I could really go for another slice of cake right now. — Same here!",
        "Same here! I also thought that movie's ending was completely disappointing.",
        "I've been craving Thai food all week. — Same here! Let's go to that new place downtown."
    ],
    "p_95": [
        "Fair enough — if you wash all the dishes, I'll take care of cleaning the kitchen floor.",
        "Fair enough. We can go to the art museum this time, since I picked the activity last weekend.",
        "You'll pay for the Uber if I buy the tickets? — Fair enough, that sounds like a good deal."
    ],
    "p_96": [
        "No way! You're telling me you've actually been inside the White House?",
        "There's no way I'm going bungee jumping — I'm way too scared of heights!",
        "No way am I paying $20 for a single cup of coffee at that fancy café."
    ],
    "p_97": [
        "Goodnight, sweetheart! Sleep tight — don't let the bedbugs bite!",
        "Sleep tight, honey! I'll see you in the morning for breakfast.",
        "It's way past your bedtime, kids — off to bed and sleep tight!"
    ],
    "p_98": [
        "Cheer up! I know you failed the test, but you can always retake it next month.",
        "Cheer up! The rainy weather will pass soon and we can go to the beach this weekend.",
        "Cheer up! Things always look better in the morning after a good night's sleep."
    ],
    "p_99": [
        "What a shame! We had to cancel the picnic because of the sudden rainstorm.",
        "What a shame! That beautiful old building got demolished to make a parking lot.",
        "What a shame you can't come to the graduation ceremony — we're going to miss you so much."
    ],
    "p_100": [
        "We've been working since 8 AM and it's already 5 PM — let's call it a day!",
        "Let's call it a day and continue fixing the car tomorrow when we're both less tired.",
        "The paint is drying, there's nothing more to do here right now. Let's call it a day!"
    ]
}

# Procesar cada tarjeta en la categoría phrases
for card in phrases_category['cards']:
    card_id = card.get('id', '')
    # Verificar si es una tarjeta de frase (empieza con p_) y NO tiene extraExamples
    if card_id.startswith('p_') and 'extraExamples' not in card and card_id in extra_examples_map:
        card['extraExamples'] = extra_examples_map[card_id]
        cards_updated += 1
        last_card_id = card_id

# Guardar el archivo modificado con indentación de 2 espacios (manteniendo estilo)
with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

# Validar que el JSON es válido
with open(file_path, 'r', encoding='utf-8') as f:
    json.load(f)

print(f"ÉXITO: Se actualizaron {cards_updated} tarjetas de frase.")
print(f"Última tarjeta procesada: {last_card_id}")
