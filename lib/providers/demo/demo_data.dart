import 'package:journal/providers/db_provider.dart';

// -----------------------------------------------------------------------------
// DEMO CHAPTERS
// -----------------------------------------------------------------------------
final List<Chapter> kDemoChapters = [
  Chapter(
    id: 'chap_adventure',
    name: 'Wild Adventures',
    description: ' Hiking, road trips, and exploring the great outdoors.',
    image: 'https://picsum.photos/id/1036/600/400', // Winter/Nature
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    lastModified: DateTime.now(),
    entryIDs: ['demo_1', 'demo_5', 'demo_10'], // Linked Entry IDs
  ),
  Chapter(
    id: 'chap_urban',
    name: 'City Living',
    description: 'Coffee shops, architecture, and nights out in the city.',
    image: 'https://picsum.photos/id/122/600/400', // Cityscape
    createdAt: DateTime.now().subtract(const Duration(days: 50)),
    lastModified: DateTime.now(),
    entryIDs: ['demo_2', 'demo_4', 'demo_7'], // Linked Entry IDs
  ),
  Chapter(
    id: 'chap_home',
    name: 'Home & Hobbies',
    description: 'Cooking, reading, and relaxing with the pup.',
    image: 'https://picsum.photos/id/1025/600/400', // Dog/Cozy
    createdAt: DateTime.now().subtract(const Duration(days: 40)),
    lastModified: DateTime.now(),
    entryIDs: ['demo_3', 'demo_6', 'demo_8', 'demo_9'], // Linked Entry IDs
  ),
];

// -----------------------------------------------------------------------------
// DEMO ENTRIES
// -----------------------------------------------------------------------------
final List<JournalEntry> kDemoEntries = [
  // 1. Hiking (Linked to Chapter: Wild Adventures)
    // 7. Concert (Linked to Chapter: City Living)
  JournalEntry(
    id: 'demo_2',
    type: EntryType.photo,
    date: DateTime.now().subtract(const Duration(days: 1)),
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    imgUrls: ['https://picsum.photos/id/452/600/400'], 
    entry: "First live concert in what feels like forever! The energy in the crowd was electric. My ears are definitely ringing, but singing along to my favorite songs with thousands of strangers was a reminder of how much I missed live music. The light show was incredible too.",
    location: "The Showbox",
    activities: [
      {'name': 'Concert', 'description': 'The Indie Collective'},
      {'name': 'Night Out', 'description': 'Drinks with friends'}
    ],
    metadatas: [{'band': 'The Indie Collective'}],
  ),

  // 8. Photography (Linked to Chapter: Home & Hobbies)
  JournalEntry(
    id: 'demo_8',
    type: EntryType.photo,
    date: DateTime.now().subtract(const Duration(days: 2)),
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    imgUrls: ['https://picsum.photos/id/250/600/400'], 
    entry: "Dusting off the old DSLR camera. I've been relying on my phone too much lately, and I miss the tactile feel of a real shutter button. Went out to the park to practice framing and playing with aperture settings. Got some decent shots of the local flora.",
    location: "Discovery Park",
    activities: [
      {'name': 'Hobby', 'description': 'Photography practice'},
      {'name': 'Walking', 'description': 'Nature walk'}
    ],
  ),

  // 9. Reading (Linked to Chapter: Home & Hobbies)
  JournalEntry(
    id: 'demo_9',
    type: EntryType.journal,
    date: DateTime.now().subtract(const Duration(days: 2)),
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    imgUrls: ['https://picsum.photos/id/24/600/400'],
    entry: "Started reading 'Atomic Habits' again this morning. It's rare to find the quiet time to just sit with a coffee and read without checking notifications every five minutes. I'm trying to make this a daily ritual before the chaos of the workday begins.",
    location: "Bedroom",
    activities: [
      {'name': 'Reading', 'description': 'Personal Development'},
      {'name': 'Morning Routine', 'description': 'Coffee & Book'}
    ],
  ),

  // 10. Cycling (Linked to Chapter: Wild Adventures)
  JournalEntry(
    id: 'demo_10',
    type: EntryType.photo,
    date: DateTime.now().subtract(const Duration(days: 28)),
    timestamp: DateTime.now().subtract(const Duration(days: 28)),
    imgUrls: ['https://picsum.photos/id/146/600/400'], 
    entry: "Pushed myself to go for a ride despite the cloudy weather. It turned out to be one of the best rides I've had all year. Cleared my head and found a new trail that cuts through the forest preserve. Definitely coming back here next weekend with a better bike light.",
    location: "Burke-Gilman Trail",
    activities: [
      {'name': 'Cycling', 'description': '15 miles'},
      {'name': 'Fitness', 'description': 'Cardio'}
    ],
    metadatas: [{'distance': '15 miles', 'avgSpeed': '12mph'}],
  ),
  JournalEntry(
    id: 'demo_1',
    type: EntryType.photo,
    date: DateTime.now().subtract(const Duration(hours: 4)),
    timestamp: DateTime.now(),
    imgUrls: ['https://picsum.photos/id/1015/600/400'], 
    entry: "We finally made it out to the valley for a hike this weekend. The air was crisp and the view from the lower ledge was absolutely worth the steep climb. It's amazing how a few hours in nature can completely reset your mindset for the week ahead. We packed a lunch and ate it overlooking the river.",
    views: 24,
    location: "Rattlesnake Ledge Trailhead",
    activities: [
      {'name': 'Hiking', 'description': '4.0 miles round trip'},
      {'name': 'Photography', 'description': 'Landscape shots'}
    ],
    metadatas: [{'device': 'iPhone 15 Pro', 'filter': 'Vivid'}],
  ),
  
  // 2. Work / Coffee (Linked to Chapter: City Living)
  JournalEntry(
    id: 'demo_22',
    type: EntryType.journal, // Showing a mix of types
    date: DateTime.now().subtract(const Duration(days: 1)),
    timestamp: DateTime.now().subtract(const Duration(days: 100)),
    imgUrls: ['https://picsum.photos/id/1/600/400'], 
    entry: "Found a quiet corner at the new coffee shop downtown to focus on some coding. I've been trying to wrap my head around this new state management pattern, and I think it finally clicked today. There is nothing quite like the feeling of solving a bug that has been plaguing you for days. The espresso here is surprisingly good, too.",
    location: "Storyboard Espresso",
    activities: [
      {'name': 'Coding', 'description': 'Flutter Project Refactor'},
      {'name': 'Deep Work', 'description': '3 hour session'}
    ],
  ),

  // 3. Cooking (Linked to Chapter: Home & Hobbies)
  JournalEntry(
    id: 'demo_3',
    type: EntryType.photo,
    date: DateTime.now().subtract(const Duration(days: 3)),
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    imgUrls: ['https://picsum.photos/id/292/600/400'], 
    entry: "Decided to skip takeout and actually cook a full meal from scratch tonight. I spent way too long chopping vegetables, but the process was honestly pretty therapeutic. The final result wasn't restaurant quality, but it tasted better knowing I made it myself. Note to self: use less salt next time.",
    location: "Home Kitchen",
    activities: [
      {'name': 'Cooking', 'description': 'Roasted Veggie Medley'},
      {'name': 'Dinner', 'description': 'Family meal'}
    ],
    metadatas: [{'recipe': 'Spicy Root Vegetables'}],
  ),

  // 4. Urban Walk (Linked to Chapter: City Living)
  JournalEntry(
    id: 'demo_4',
    type: EntryType.photo,
    date: DateTime.now().subtract(const Duration(days: 5)),
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
    imgUrls: ['https://picsum.photos/id/122/600/400'], 
    entry: "Took a long walk through the city this evening just as the sun was setting. I usually rush through these streets to get to appointments, but slowing down lets you appreciate the architecture. The way the light reflects off the glass buildings at golden hour is just stunning.",
    location: "Downtown Financial District",
    activities: [
      {'name': 'Walking', 'description': 'Urban exploration'},
      {'name': 'Sightseeing', 'description': 'Architecture tour'}
    ],
  ),

  // 5. Beach (Linked to Chapter: Wild Adventures)
  JournalEntry(
    id: 'demo_5',
    type: EntryType.photo,
    date: DateTime.now().subtract(const Duration(days: 8)),
    timestamp: DateTime.now().subtract(const Duration(days: 8)),
    imgUrls: ['https://picsum.photos/id/1050/600/400'], 
    entry: "Needed a break from the screens, so we drove out to the coast. The sound of the waves crashing is the best white noise in the world. We just sat on the sand for hours, watching the tide come in and talking about everything and nothing. It was windy, but refreshing.",
    location: "Cannon Beach",
    activities: [
      {'name': 'Road Trip', 'description': 'Coastal drive'},
      {'name': 'Relaxing', 'description': 'Beach combing'}
    ],
    metadatas: [{'weather': 'Overcast', 'temp': '62F'}],
  ),

  // 6. Pets (Linked to Chapter: Home & Hobbies)
  JournalEntry(
    id: 'demo_6',
    type: EntryType.photo,
    date: DateTime.now().subtract(const Duration(days: 12)),
    timestamp: DateTime.now().subtract(const Duration(days: 12)),
    imgUrls: ['https://picsum.photos/id/1025/600/400'], 
    entry: "This little guy has the right idea for a rainy Sunday. Neither of us has moved from the couch in about three hours. Sometimes you just need a lazy day to recharge the batteries and catch up on some reading while the dog snores beside you.",
    location: "Living Room",
    activities: [
      {'name': 'Nap', 'description': 'Afternoon siesta'},
      {'name': 'Pet Care', 'description': 'Dog sitting'}
    ],
  ),


];