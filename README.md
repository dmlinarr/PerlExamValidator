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

```bash
perl t/Cheating.t
```

```bash
perl t/Exam_Reader.t
```

```bash
perl -e 'for (glob "t/*.t") { system("perl $_") }'
```

### Documentation

```bash
perldoc lib/Cheating.pm
```