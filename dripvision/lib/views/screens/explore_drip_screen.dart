import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class ExploreDripScreen extends StatelessWidget {
  const ExploreDripScreen({super.key});

  Future<void> _upvoteAndRewardCreator(String docId, String creatorId) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.runTransaction((transaction) async {
      final docRef = firestore.collection('public_feed').doc(docId);
      final creatorRef = firestore.collection('users').doc(creatorId);
      transaction.update(docRef, {'upvotes': FieldValue.increment(1)});
      transaction.update(creatorRef, {'tokenBalance': FieldValue.increment(2)});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'EXPLORE DRIP',
          style: TextStyle(
            color: DripTheme.nebulaCyan,
            fontWeight: FontWeight.black,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: DripTheme.cosmicTeal,
                blurRadius: 15,
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('public_feed')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load feed', style: TextStyle(color: Colors.white54)),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: DripTheme.cosmicTeal),
            );
          }

          final posts = snapshot.data!.docs;
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'No drips yet. Be the first.',
                style: TextStyle(color: Colors.white30),
              ),
            );
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    post['thumbnailUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: DripTheme.surface),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          DripTheme.voidBlack.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: 20,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${post['creatorName'] ?? 'anon'}',
                          style: const TextStyle(
                            color: DripTheme.nebulaCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post['prompt'] ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 20,
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.bolt,
                            color: DripTheme.nebulaCyan,
                            size: 36,
                          ),
                          onPressed: () => _upvoteAndRewardCreator(
                            posts[index].id,
                            post['creatorId'],
                          ),
                        ),
                        Text(
                          '${post['upvotes'] ?? 0}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        const Icon(Icons.share, color: Colors.white54, size: 28),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
