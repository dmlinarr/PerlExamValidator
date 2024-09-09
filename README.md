### Main task (part 1a)

```bash
perl src/Exam_Randomizer.pl resource/normal-exam/IntroPerlEntryExam.txt
```

```bash
perl src/Exam_Randomizer.pl resource/short-exam/IntroPerlEntryExamShort.txt
```

### Main task (part 1b)

```bash
perl src/Exam_Scorer.pl resource/normal-exam/IntroPerlEntryExam.txt resource/normal-exam/*
```

```bash
perl src/Exam_Scorer.pl resource/short-exam/IntroPerlEntryExamShort.txt resource/short-exam/*
```

### Testing

```bash
perl t/Statistics.t 
```

Cheating.pm
Exam_Reader.pm