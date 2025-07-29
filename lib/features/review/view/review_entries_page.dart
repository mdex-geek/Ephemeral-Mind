import 'package:flutter/material.dart';
import '../data/entry_model.dart';
import '../widgets/entry_card.dart';

class ReviewEntriesPage extends StatefulWidget {
  const ReviewEntriesPage({super.key});

  @override
  State<ReviewEntriesPage> createState() => _ReviewEntriesPageState();
}

final entries = [
      Entry('Ephemeral Mind', 'Today, 2:15 PM', "Reflecting on today's fleeting thoughts. The quiet moments often hold the deepest insights, yet they are the quickest to vanish if not acknowledged.", Colors.purple),
      Entry('Ephemeral Mind', 'Yesterday, 10:30 AM', "A sudden realization about the nature of creativity. It's less about finding new ideas and more about connecting existing ones in novel ways.", Colors.purple),
      Entry('Ephemeral Mind', '2 days ago, 7:00 PM', "Felt a strong sense of gratitude this morning. A simple act of kindness can truly brighten an entire day for someone, and for yourself.", Colors.green),
      Entry('Ephemeral Mind', '3 days ago, 9:45 AM', "The challenge of staying present in a world full of distractions. Mindfulness isn't a destination, but a continuous journey of return.", Colors.orange),
      Entry('Ephemeral Mind', 'Last Week, 6:00 PM', "Experimented with a new recipe tonight. The joy of culinary creation lies in the process as much as the outcome.", Colors.black),
      Entry('Ephemeral Mind', 'Last Week, 6:00 PM', "Experimented with a new recipe tonight. The joy of culinary creation lies in the process as much as the outcome. ohrhwpguoaewprufbgpaeubvuerpiybvjbrepiubspivbbrvbsfrvpirbisbvibvpiryajujjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjqqiubivbseirbgihrbfibbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", Colors.black),
    ];
    

class _ReviewEntriesPageState extends State<ReviewEntriesPage> {
  @override
  Widget build(BuildContext context) {
    

    void deleteEntry(int index)
    {
      setState(() {
        entries.removeAt(index);
      });
    }

    void saveEntry(int index)
    {
      setState(() {
        entries[index].isSaved = !entries[index].isSaved;
      });
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, i) => EntryCard(entry: entries[i],index:i,onDelete:deleteEntry,onSave:saveEntry),
      ),
    );
  }
} 