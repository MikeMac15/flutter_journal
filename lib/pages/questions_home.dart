import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/menu_buttons/image_button.dart';
import 'package:journal/pages/chapters/chapters_page.dart';
import 'package:journal/pages/questionWalls/questions/questions_main_page.dart';
import 'package:journal/pages/questionWalls/year_in_review_questions_page.dart';
import 'package:journal/pages/questionWalls/ranked_list_memories/ranked_list_home.dart';

/// A layout page that shows a centered large button
/// and a scrollable horizontal list of small cards.
class QuestionsHome extends StatelessWidget {
  const QuestionsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final largeButtons = [{
      'title': 'Year in Review',
      'page': const YearInReviewQuestionsPage(),
      'asset': 'assets/images/questions/disco.png',
    },
    {
      'title': 'Questions',
      'page': const QuestionsMainPage(),
      'asset': 'assets/images/questions/questionSky.png',
    },
    {
      'title': 'Wall of Firsts',
      'page': const RankedListHome(),
      'asset': 'assets/images/questions/firsts.png',
    },
    {
      'title': 'Chapters',
      'page': const ChaptersPage(),
      'asset': 'assets/images/questions/chapters.png',
  }
    ];


    return Scaffold(
      // appBar: AppBar(title: const Text('Questions Home'), surfaceTintColor: Theme.of(context).colorScheme.surfaceTint),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              // Large full-width image button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: LargeImageButton(
                  title: largeButtons[0]['title'] as String,
                  backgroundImage: AssetImage(largeButtons[0]['asset'] as String),
                  onPressed: () => Navigator.of(context).push(
                    fadeRoute(largeButtons[0]['page'] as Widget),
                  ),
                ),
              ),


              const SizedBox(height: 24),
              
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: LargeImageButton(
                  title: largeButtons[1]['title'] as String,
                  backgroundImage: AssetImage(largeButtons[1]['asset'] as String),
                  onPressed: () => Navigator.of(context).push(
                    fadeRoute(largeButtons[1]['page'] as Widget),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: LargeImageButton(
                  title: largeButtons[2]['title'] as String,
                  backgroundImage: AssetImage(largeButtons[2]['asset'] as String),
                  onPressed: () => Navigator.of(context).push(
                    fadeRoute(largeButtons[2]['page'] as Widget),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: LargeImageButton(
                  title: largeButtons[3]['title'] as String,
                  backgroundImage: AssetImage(largeButtons[3]['asset'] as String),
                  onPressed: () => Navigator.of(context).push(
                    fadeRoute(largeButtons[3]['page'] as Widget),
                  ),
                ),
              ),
              const SizedBox(height: 24),







              const SizedBox(height: 32),
              // Title for the small cards section
              const Row(
                
                children: [
                  // Text(
                  //   'Add new event:',
                  //   style: TextStyle(
                  //     fontSize: 14,
                      
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 6),
              // Scrollable row of cards
              // SizedBox(
              //   height: 100,
              //   child: ListView.separated(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: smallCards.length,
              //     separatorBuilder: (_, __) => const SizedBox(width: 16),
              //     itemBuilder: (context, index) {
              //       final btn = smallCards[index];
              //       return Card(
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //         clipBehavior: Clip.hardEdge,
              //         child: InkWell(
              //           onTap: () => Navigator.of(context).push(
              //             fadeRoute(btn['page'] as Widget),
              //           ),
              //           child: SizedBox(
                          
                          
              //             child: SmallImageButton(
              //               height: 40,
              //               title: btn['title'] as String,
              //               backgroundImage:
              //                   AssetImage(btn['asset'] as String),
              //               onPressed: () => Navigator.of(context).push(
              //                 fadeRoute(btn['page'] as Widget),
              //               ),
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
