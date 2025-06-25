import 'package:music_notes/music_notes.dart';

final List<ScalePattern> kScalePatterns = [
  ScalePattern.chromatic,
  ScalePattern.dorian,
  ScalePattern.doubleHarmonicMajor,
  ScalePattern.harmonicMinor,
  ScalePattern.locrian,
  ScalePattern.lydian,
  ScalePattern.lydianAugmented,
  ScalePattern.major,
  ScalePattern.majorPentatonic,
  ScalePattern.melodicMinor,
  ScalePattern.minorPentatonic,
  ScalePattern.mixolydian,
  ScalePattern.naturalMinor,
  ScalePattern.octatonic,
  ScalePattern.phrygian,
  ScalePattern.wholeTone,
];

final List<Note> kScaleNotes = [
  Note.a.natural,
  Note.a.sharp,
  Note.a.flat,
  Note.b.natural,
  Note.b.sharp,
  Note.b.flat,
  Note.c.natural,
  Note.c.sharp,
  Note.c.flat,
  Note.d.natural,
  Note.d.sharp,
  Note.d.flat,
  Note.e.natural,
  Note.e.sharp,
  Note.e.flat,
  Note.f.natural,
  Note.f.sharp,
  Note.f.flat,
  Note.g.natural,
  Note.g.sharp,
  Note.g.flat,
];

List<List<Scale<Note>>> kScaleGroups = List.empty(growable: true);
List<List<Scale<Note>>> kScaleGroupsInverse = List.empty(growable: true);

void initScalePatternGroups() {
  for (var note in kScaleNotes) {
    final List<Scale<Note>> patterns = [];
    for (var scale in kScalePatterns) {
      bool shouldAdd = true;
      for (var list in kScaleGroups) {
        for (var existing in list) {
          if (scale.on(note).isEnharmonicWith(existing)) {
            shouldAdd = false;
            break;
          }
        }
      }
      if (shouldAdd) patterns.add(scale.on(note));
    }
    kScaleGroups.add(patterns);
  }

  for(var scalePattern in kScalePatterns){
    List<Scale<Note>> patterns = [];
    for(var note in kScaleNotes){
      Scale<Note> scale =  scalePattern.on(note);
      bool shouldAdd = true;
      for (var group in kScaleGroupsInverse) {
        for (var existing in group) {
          if (existing.pattern == scale.pattern && (scale.isEnharmonicWith(existing) || scale.degree(ScaleDegree.i) == existing.degree(ScaleDegree.i))) {
        shouldAdd = false;
        break;
          }
        }
        if (!shouldAdd) break;
      }
      if (shouldAdd) patterns.add(scale);
    }
    kScaleGroupsInverse.add(patterns);
  }
}


