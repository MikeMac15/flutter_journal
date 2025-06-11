import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/menu_buttons/image_button.dart';
import 'package:journal/features/questionWalls/year_in_review_questions_page.dart';

/// A layout page that shows a centered large button
/// and a scrollable horizontal list of small cards.
class QuestionsHome extends StatelessWidget {
  const QuestionsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final largeButton = {
      'title': 'Year in Review',
      'page': const YearInReviewQuestionsPage(),
      'asset': 'assets/images/questions/yearInReview.png',
    };

    final smallCards = [
      {
        'title': 'Concert',
        'page': const YearInReviewQuestionsPage(), // replace
        'asset': 'assets/images/questions/concerts.png',
      },
      {
        'title': 'Book',
        'page': const YearInReviewQuestionsPage(), // replace
        'asset': 'assets/images/questions/favoritesWall.png',
      },
      {
        'title': 'Tv Show',
        'page': const YearInReviewQuestionsPage(), // replace
        'asset': 'assets/images/questions/monthlyRecap.png',
      },
      {
        'title': 'Vacations',
        'page': const YearInReviewQuestionsPage(), // replace
        'asset': 'assets/images/questions/concerts.png',
      },
      {
        'title': '',
        'page': const YearInReviewQuestionsPage(), // replace
        'asset': 'assets/images/questions/favoritesWall.png',
      },
      {
        'title': 'Tv Show',
        'page': const YearInReviewQuestionsPage(), // replace
        'asset': 'assets/images/questions/monthlyRecap.png',
      },
      // add more entries as needed...
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Questions Home')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              // Large full-width image button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: LargeImageButton(
                  title: largeButton['title'] as String,
                  backgroundImage: AssetImage(largeButton['asset'] as String),
                  onPressed: () => Navigator.of(context).push(
                    fadeRoute(largeButton['page'] as Widget),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              // Title for the small cards section
              const Row(
                
                children: [
                  Text(
                    'Add new event:',
                    style: TextStyle(
                      fontSize: 14,
                      
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Scrollable row of cards
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: smallCards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final btn = smallCards[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          fadeRoute(btn['page'] as Widget),
                        ),
                        child: SizedBox(
                          
                          
                          child: SmallImageButton(
                            height: 40,
                            title: btn['title'] as String,
                            backgroundImage:
                                AssetImage(btn['asset'] as String),
                            onPressed: () => Navigator.of(context).push(
                              fadeRoute(btn['page'] as Widget),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
