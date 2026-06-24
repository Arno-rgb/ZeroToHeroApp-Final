export type ProgrammeExercise = {
  id: string;
  name: string;
  target: string;
  restSeconds: number;
  instructions: string[];
  coachNote: string;
};

export type ProgrammeDay = {
  day: number;
  title: string;
  focus: string;
  durationMinutes: number;
  exercises: ProgrammeExercise[];
};

export const coachConfig = {
  brandName: 'Zero to Hero Coaching',
  trainerName: 'Coach Arno',
  headline: '7-Day Bodyweight Starter Plan',
  subheadline: 'A clean mobile demo trainers can show clients in under one minute.',
  whatsappNumber: '27820000000',
  whatsappMessage:
    'Hi Coach Arno, I saw the training app demo and want to try it with my clients.',
  logoPath: '/images/logo.png',
  colors: {
    primary: '#0f766e',
    accent: '#f2c94c',
    ink: '#172033',
    muted: '#667085',
    surface: '#f7faf8',
  },
  programme: [
    {
      day: 1,
      title: 'Foundation Strength',
      focus: 'Learn the rhythm and finish fresh.',
      durationMinutes: 22,
      exercises: [
        {
          id: 'd1-warmup',
          name: 'Warm-up Flow',
          target: '3 minutes',
          restSeconds: 30,
          instructions: [
            'March in place for 60 seconds.',
            'Add arm circles for 30 seconds each direction.',
            'Finish with easy hip hinges and ankle bounces.',
          ],
          coachNote: 'The warm-up should feel light, not tiring.',
        },
        {
          id: 'd1-squat',
          name: 'Tempo Squat',
          target: '3 sets x 10 reps',
          restSeconds: 45,
          instructions: [
            'Feet shoulder-width apart.',
            'Lower for three seconds, pause briefly, stand tall.',
            'Keep knees tracking over toes.',
          ],
          coachNote: 'Reduce depth if the back rounds.',
        },
        {
          id: 'd1-pushup',
          name: 'Incline Push-up',
          target: '3 sets x 8 reps',
          restSeconds: 45,
          instructions: [
            'Use a counter, bench, or wall.',
            'Brace your body in one straight line.',
            'Lower chest toward the support and press away.',
          ],
          coachNote: 'Move to a higher incline if form breaks.',
        },
        {
          id: 'd1-core',
          name: 'Dead Bug',
          target: '2 sets x 8 each side',
          restSeconds: 35,
          instructions: [
            'Lie on your back with knees above hips.',
            'Slowly extend opposite arm and leg.',
            'Keep ribs down and lower back steady.',
          ],
          coachNote: 'Slow reps beat fast reps here.',
        },
      ],
    },
    {
      day: 2,
      title: 'Core & Posture',
      focus: 'Build control through the trunk.',
      durationMinutes: 20,
      exercises: [
        {
          id: 'd2-mobility',
          name: 'Shoulder Reset',
          target: '2 rounds x 45 seconds',
          restSeconds: 25,
          instructions: [
            'Stand tall with ribs down.',
            'Sweep arms overhead without shrugging.',
            'Squeeze shoulder blades gently on the way down.',
          ],
          coachNote: 'Keep breathing smooth.',
        },
        {
          id: 'd2-plank',
          name: 'High Plank Hold',
          target: '4 x 20 seconds',
          restSeconds: 40,
          instructions: [
            'Hands under shoulders.',
            'Push the floor away.',
            'Squeeze glutes and keep hips level.',
          ],
          coachNote: 'Stop the set before your hips sag.',
        },
        {
          id: 'd2-bridge',
          name: 'Glute Bridge',
          target: '3 sets x 12 reps',
          restSeconds: 35,
          instructions: [
            'Feet flat, knees bent.',
            'Drive through heels and lift hips.',
            'Pause at the top without arching the lower back.',
          ],
          coachNote: 'This supports squats and running mechanics.',
        },
      ],
    },
    {
      day: 3,
      title: 'Conditioning Base',
      focus: 'Raise the heart rate without sprinting.',
      durationMinutes: 24,
      exercises: [
        {
          id: 'd3-step',
          name: 'Step-back Lunge',
          target: '3 sets x 8 each leg',
          restSeconds: 45,
          instructions: [
            'Step back softly.',
            'Drop the back knee toward the floor.',
            'Drive through the front foot to stand.',
          ],
          coachNote: 'Hold a wall for balance if needed.',
        },
        {
          id: 'd3-mountain',
          name: 'Slow Mountain Climber',
          target: '4 x 30 seconds',
          restSeconds: 40,
          instructions: [
            'Start in a high plank.',
            'Bring one knee forward at a controlled pace.',
            'Keep shoulders stacked over hands.',
          ],
          coachNote: 'Quality beats speed.',
        },
        {
          id: 'd3-walk',
          name: 'Brisk Walk Finisher',
          target: '8 minutes',
          restSeconds: 0,
          instructions: [
            'Walk at a pace where talking takes effort.',
            'Keep shoulders relaxed.',
            'Breathe through the nose when possible.',
          ],
          coachNote: 'A client can do this indoors or outside.',
        },
      ],
    },
    {
      day: 4,
      title: 'Recovery Mobility',
      focus: 'Move well and reduce soreness.',
      durationMinutes: 16,
      exercises: [
        {
          id: 'd4-catcow',
          name: 'Cat-Cow',
          target: '2 minutes',
          restSeconds: 20,
          instructions: [
            'Move slowly between round and extended spine.',
            'Match each rep with a full breath.',
            'Keep pressure even through both hands.',
          ],
          coachNote: 'This is a recovery day, not a test.',
        },
        {
          id: 'd4-hip',
          name: 'Hip Flexor Stretch',
          target: '2 x 40 seconds each side',
          restSeconds: 20,
          instructions: [
            'Half-kneel with front foot flat.',
            'Tuck pelvis gently.',
            'Shift forward until the front of the hip opens.',
          ],
          coachNote: 'No sharp knee or back discomfort.',
        },
        {
          id: 'd4-breath',
          name: 'Box Breathing',
          target: '4 rounds',
          restSeconds: 0,
          instructions: [
            'Inhale for four seconds.',
            'Hold for four seconds.',
            'Exhale for four seconds, then hold for four.',
          ],
          coachNote: 'A useful habit after training.',
        },
      ],
    },
    {
      day: 5,
      title: 'Strength Ladder',
      focus: 'Add volume without rushing.',
      durationMinutes: 25,
      exercises: [
        {
          id: 'd5-squat',
          name: 'Squat Ladder',
          target: '6-8-10-8-6 reps',
          restSeconds: 45,
          instructions: [
            'Stand tall between sets.',
            'Keep the same clean depth each round.',
            'Rest before speed changes your form.',
          ],
          coachNote: 'Clients feel progression without maxing out.',
        },
        {
          id: 'd5-push',
          name: 'Push-up Ladder',
          target: '4-6-8-6-4 reps',
          restSeconds: 45,
          instructions: [
            'Choose wall, incline, knee, or floor level.',
            'Brace before each rep.',
            'Finish every rep with locked-out arms.',
          ],
          coachNote: 'Scale the angle, not the quality.',
        },
        {
          id: 'd5-hollow',
          name: 'Hollow Hold',
          target: '4 x 15 seconds',
          restSeconds: 35,
          instructions: [
            'Press lower back toward the floor.',
            'Reach arms forward if overhead is too hard.',
            'Stop when the back arches.',
          ],
          coachNote: 'Core strength should feel controlled.',
        },
      ],
    },
    {
      day: 6,
      title: 'Full Body Circuit',
      focus: 'Put the week together.',
      durationMinutes: 28,
      exercises: [
        {
          id: 'd6-circuit',
          name: 'Three-Round Circuit',
          target: '3 rounds',
          restSeconds: 60,
          instructions: [
            '10 squats.',
            '8 incline push-ups.',
            '12 glute bridges.',
            '30 seconds brisk march.',
          ],
          coachNote: 'Rest between rounds, not between every move.',
        },
        {
          id: 'd6-side',
          name: 'Side Plank',
          target: '2 x 20 seconds each side',
          restSeconds: 30,
          instructions: [
            'Elbow under shoulder.',
            'Stack feet or place top foot forward.',
            'Lift hips and keep chest open.',
          ],
          coachNote: 'Use knees down for a beginner option.',
        },
      ],
    },
    {
      day: 7,
      title: 'Check-in Session',
      focus: 'Measure consistency and confidence.',
      durationMinutes: 18,
      exercises: [
        {
          id: 'd7-check',
          name: 'Quality Rep Check',
          target: '2 sets each movement',
          restSeconds: 45,
          instructions: [
            'Do 8 squats, 6 push-ups, and 8 dead bugs.',
            'Score each movement as easy, moderate, or hard.',
            'Keep one rep in reserve.',
          ],
          coachNote: 'This gives the trainer an easy follow-up message.',
        },
        {
          id: 'd7-walk',
          name: 'Easy Walk',
          target: '10 minutes',
          restSeconds: 0,
          instructions: [
            'Walk comfortably.',
            'Notice breathing and posture.',
            'Finish with two minutes of light stretching.',
          ],
          coachNote: 'End the week with a win.',
        },
      ],
    },
  ] satisfies ProgrammeDay[],
};

export type CoachConfig = typeof coachConfig;

