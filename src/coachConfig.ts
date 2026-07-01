export type ExerciseVisualKind = 'squat' | 'lunge' | 'push' | 'pull' | 'row' | 'hinge' | 'core' | 'jump' | 'burpee' | 'hang' | 'handstand' | 'crawl' | 'run' | 'default';

export type ProgrammeExercise = {
  id: string;
  name: string;
  target: string;
  description: string;
  visualKind: ExerciseVisualKind;
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

export type CoachProgramme = {
  id: string;
  title: string;
  level: string;
  subtitle: string;
  durationLabel: string;
  days: ProgrammeDay[];
};

type ExerciseEntry = readonly [name: string, target: string, restSeconds?: number];
type WorkoutEntry = {
  title: string;
  focus: string;
  durationMinutes: number;
  exercises: readonly ExerciseEntry[];
};

type ExerciseGuide = {
  description: string;
  method: string;
  easier: string;
  keyStandard: string;
  visualKind: ExerciseVisualKind;
  caution?: string;
};

function guide(
  visualKind: ExerciseVisualKind,
  description: string,
  method: string,
  easier: string,
  keyStandard: string,
  caution?: string
): ExerciseGuide {
  return { visualKind, description, method, easier, keyStandard, caution };
}

const exerciseGuides: Record<string, ExerciseGuide> = {
  'chair-squat': guide(
    'squat',
    'Beginner squat pattern for learning controlled sit-to-stand mechanics.',
    'Stand in front of a chair, reach the hips back, touch the chair lightly, and stand by pressing through the whole foot.',
    'Use a higher seat and push lightly from the thighs.',
    'Knees track in the same direction as the toes.'
  ),
  'bodyweight-squat': guide(
    'squat',
    'General leg strength and squat control.',
    'Stand in a comfortable stance, bend at the hips and knees together, descend only as far as control allows, then stand tall.',
    'Squat to a chair.',
    'Heels remain grounded and the knees do not collapse inward.'
  ),
  squat: guide(
    'squat',
    'Knee-dominant leg strength with controlled depth.',
    'Stand in a comfortable stance, bend the hips and knees together, then stand tall through the whole foot.',
    'Squat to a chair or reduce the depth.',
    'Keep the heels grounded and the knees tracking with the toes.'
  ),
  'deep-squat': guide(
    'squat',
    'A deeper squat variation for mobility and leg strength.',
    'Descend only as far as balance and spinal control allow, pause briefly, then stand without bouncing.',
    'Use a normal squat depth or hold a stable support.',
    'Depth is only useful while the heels, knees, and trunk stay controlled.'
  ),
  'wall-sit': guide(
    'squat',
    'Isometric quadriceps endurance.',
    'Lean against a wall, slide to a sustainable knee angle, and hold while breathing normally.',
    'Use a higher position.',
    'Stop if knee discomfort increases.'
  ),
  'pistol-squat': guide(
    'squat',
    'Advanced single-leg squat strength and balance.',
    'Lower on one leg while the other leg reaches forward, then stand from a range you can reverse cleanly.',
    'Hold support or squat to a box.',
    'Keep the working heel down and the pelvis controlled.'
  ),
  'shrimp-squat': guide(
    'squat',
    'Advanced single-leg strength with the free leg behind the body.',
    'Stand on one leg, bend the free knee behind you, lower under control, and stand without twisting.',
    'Hold support or use a smaller range.',
    'The working knee stays aligned over the foot.'
  ),
  'back-lunge': guide(
    'lunge',
    'One-leg strength with a stable return.',
    'Step back, lower both knees under control, then drive through the front foot to stand.',
    'Hold support or shorten the step.',
    'Keep most pressure through the front foot.'
  ),
  'front-lunge': guide(
    'lunge',
    'Forward step strength and deceleration.',
    'Step forward, absorb the landing, lower under control, and push back to the start.',
    'Use a shorter step and shallow depth.',
    'Land quietly and control the front knee.'
  ),
  'alternating-lateral-lunge': guide(
    'lunge',
    'Side-to-side leg strength and hip control.',
    'Step wide, sit the hips toward the stepping side, keep the other leg long, and return to centre.',
    'Reduce step width and depth.',
    'Keep the planted foot flat.'
  ),
  'alternating-cross-over-lunge': guide(
    'lunge',
    'Lunge variation that challenges balance and hip control.',
    'Step diagonally behind the body, lower with control, and return to a tall stance before switching sides.',
    'Use a smaller step or hold support.',
    'Keep the front foot planted and the knee controlled.'
  ),
  'bulgarian-split-squat': guide(
    'lunge',
    'Rear-foot-elevated single-leg strength.',
    'Place the rear foot on a low support, lower through the front leg, and stand without bouncing off the rear leg.',
    'Keep the rear foot on the floor.',
    'The front leg performs most of the work.'
  ),
  't-stand': guide(
    'lunge',
    'Single-leg balance and hip control.',
    'Hinge on one leg with the free leg reaching back, then return to standing with control.',
    'Keep a hand near support or reduce the hinge depth.',
    'Keep the hips square and the standing knee soft.'
  ),
  't-stand-jump': guide(
    'jump',
    'A balance-to-power drill for advanced trainees.',
    'Move from a controlled single-leg hinge into a small jump or fast stand, then land quietly.',
    'Remove the jump and perform a normal T-stand.',
    'Reset if the landing knee collapses inward.'
  ),
  'skater-jump': guide(
    'jump',
    'Lateral power and landing control.',
    'Jump sideways from one leg to the other and absorb the landing before repeating.',
    'Use a skater step instead of a jump.',
    'The landing knee tracks over the toes.'
  ),
  pedal: guide(
    'core',
    'Alternating trunk and hip flexion conditioning.',
    'Move one knee at a time with the trunk braced and the pelvis quiet.',
    'Slow the tempo or reduce the range.',
    'Speed never exceeds control.'
  ),
  'standard-push-up': guide(
    'push',
    'Horizontal pressing strength for chest, shoulders, triceps, and trunk.',
    'From a high plank, lower the chest between the hands and press back to the top.',
    'Use an incline push-up.',
    'Maintain one line from head to heels.'
  ),
  'wall-push-up': guide(
    'push',
    'Beginner pressing pattern with trunk alignment.',
    'Place the hands on a wall, lower the chest toward it, and press away while the body stays straight.',
    'Stand closer to the wall.',
    'Elbows travel diagonally back, not directly sideways.'
  ),
  'incline-push-up': guide(
    'push',
    'Bridge between wall and floor push-ups.',
    'Use a stable elevated surface and perform a full-body push-up.',
    'Use a higher surface.',
    'The torso and hips rise together.'
  ),
  'push-up': guide(
    'push',
    'Floor pressing strength for chest, shoulders, triceps, and trunk.',
    'From a high plank, lower the chest between the hands and press back to the top.',
    'Use an incline push-up.',
    'Maintain one line from head to heels.'
  ),
  'military-push-up': guide(
    'push',
    'Close-elbow push-up variation with extra triceps demand.',
    'Place the hands around shoulder width and keep the elbows near the torso as you lower and press.',
    'Perform the movement on an incline.',
    'Use a hand width that does not irritate the wrists.'
  ),
  'close-grip-push-up': guide(
    'push',
    'Triceps-focused push-up variation.',
    'Place the hands slightly narrower than shoulder width and keep the elbows close to the body.',
    'Use an incline surface.',
    'The torso and hips rise together.'
  ),
  'down-dog-push-up': guide(
    'push',
    'Overhead pressing strength from an inverted-V position.',
    'Form an inverted V, bend the elbows, and lower the head toward the floor between the hands.',
    'Use elevated hands and a shallow range.',
    'The head moves forward and down between the hands.'
  ),
  'pike-push-up-to-push-up': guide(
    'push',
    'Combined overhead and horizontal pressing.',
    'Move from a pike push-up into a plank push-up while keeping each repetition controlled.',
    'Separate the two movements or use elevated hands.',
    'Do not rush the transition if the trunk loses position.'
  ),
  'stop-and-go-push-up': guide(
    'push',
    'Push-up control with a deliberate pause.',
    'Lower under control, pause briefly near the bottom, then press up without collapsing.',
    'Use an incline or shorten the pause.',
    'The pause should not change the body line.'
  ),
  'archer-push-up': guide(
    'push',
    'Advanced pressing that shifts more load to one side.',
    'Use a wide hand position and shift toward one arm while the other stays more extended.',
    'Use an incline or a smaller side shift.',
    'Keep the hips square.'
  ),
  'one-arm-push-up': guide(
    'push',
    'High relative pressing strength.',
    'Use one working hand and a wide foot stance, lowering without rotating away from the floor.',
    'Use an elevated surface or fingertip assistance.',
    'Progress gradually and do not force depth.'
  ),
  'plyometric-push-up': guide(
    'push',
    'Upper-body power with a controlled landing.',
    'Press fast enough for the hands to become light or leave the floor, then land with soft elbows.',
    'Use fast non-airborne push-ups or an incline.',
    'Every landing is quiet and stable.'
  ),
  'spiderman-push-up': guide(
    'push',
    'Push-up variation that adds hip and trunk control.',
    'As you lower, bring one knee toward the same-side elbow, then press up and switch sides.',
    'Use a normal push-up or move one knee at a time slowly.',
    'Keep the hips from sagging or twisting hard.'
  ),
  'push-up-jack': guide(
    'push',
    'Conditioning push-up with a jumping foot action.',
    'Hold a strong plank while the feet jump out and in, adding a push-up only if control remains.',
    'Step the feet instead of jumping.',
    'Keep the pelvis level.'
  ),
  'backward-push-up': guide(
    'push',
    'Advanced push-up variation requiring shoulder and trunk control.',
    'Move through the programmed range slowly and keep the body braced from shoulders to feet.',
    'Use a standard or incline push-up.',
    'Stop before the shoulders or lower back lose position.'
  ),
  'forearm-push-up': guide(
    'push',
    'Pressing variation that moves between forearm and hand support.',
    'Keep a plank line while pressing from forearms toward the hands or lowering back under control.',
    'Use elevated hands or reduce the range.',
    'Do not let the hips twist from side to side.'
  ),
  dip: guide(
    'push',
    'Bodyweight pressing for triceps, chest, and shoulders.',
    'Support the body on secure handles, lower only through a pain-free range, and press back up.',
    'Use foot assistance or a smaller range.',
    'Keep the shoulders controlled and stop if the front of the shoulder hurts.'
  ),
  'pull-up': guide(
    'pull',
    'Strict overhand vertical pulling strength.',
    'Pull from an active hang until the chin reaches bar height, then lower under control.',
    'Use assistance or eccentric-only repetitions.',
    'Avoid swinging or kicking unless a coach has programmed that skill.'
  ),
  'chin-up': guide(
    'pull',
    'Underhand vertical pulling strength.',
    'Begin from a controlled hang, drive the elbows down, and pull until the chin clears the bar.',
    'Use a band, foot assistance, or slow negatives.',
    'Begin each repetition from a stable shoulder position.'
  ),
  'l-sit-chin-up': guide(
    'pull',
    'Advanced chin-up variation with trunk compression.',
    'Hold a tuck or L-sit position while performing strict chin-ups under control.',
    'Use a normal chin-up or tuck the knees.',
    'Do not swing the legs to finish the pull.'
  ),
  'one-arm-chin-up': guide(
    'pull',
    'Assisted progression toward one-arm pulling strength.',
    'Pull mainly with one arm while the other hand assists through a strap, band, or lower grip.',
    'Use standard chin-ups and slow negatives.',
    'Avoid uncontrolled one-arm negatives, which can overload the elbow.',
    'Use coach supervision for this advanced progression.'
  ),
  'inverted-bodyweight-row': guide(
    'row',
    'Horizontal pulling strength with a rigid body line.',
    'Hang beneath a secure bar or straps and pull the chest toward the hands while the body stays rigid.',
    'Stand more upright or bend the knees.',
    'Finish by drawing the shoulder blades back, not by jutting the chin.'
  ),
  'close-grip-inverted-row': guide(
    'row',
    'Horizontal pulling with a narrower grip.',
    'Row toward the hands with the body braced and the elbows tracking close to the torso.',
    'Use a more upright body angle.',
    'Keep the shoulders and hips moving together.'
  ),
  'one-arm-inverted-row': guide(
    'row',
    'Unilateral horizontal pulling strength.',
    'Pull with one arm while keeping the shoulders and hips square.',
    'Use two hands with one hand providing light assistance.',
    'Use a secure setup and stop before grip failure.'
  ),
  'archer-pull-up': guide(
    'pull',
    'Advanced pull-up that shifts more load to one side.',
    'Pull toward one hand while the other arm assists and stays more extended.',
    'Use assisted pull-ups or archer rows.',
    'Resist trunk rotation and avoid elbow strain.'
  ),
  'plyometric-inverted-row': guide(
    'row',
    'Power-focused horizontal pulling.',
    'Row explosively enough for the hands to become light, then reconnect and lower under control.',
    'Use fast but non-airborne rows.',
    'Keep the landing through the arms quiet and stable.'
  ),
  'neo-row': guide(
    'row',
    'Advanced row variation with higher trunk-control demand.',
    'Row from a secure setup and control the shoulders, hips, and grip through each repetition.',
    'Use a standard body row.',
    'Do not add speed until the row path is stable.'
  ),
  'dead-hang': guide(
    'hang',
    'Grip and shoulder tolerance from a hanging position.',
    'Hang from a secure bar with controlled shoulders and steady breathing.',
    'Keep the feet partly supported.',
    'Do not shrug hard or swing.'
  ),
  'front-lever': guide(
    'hang',
    'Advanced straight-arm pulling and trunk tension.',
    'From a hang, draw the knees in or extend the body toward horizontal while keeping the shoulders active.',
    'Use tuck front-lever holds or short tuck raises.',
    'Do not drop suddenly out of the position.'
  ),
  'skin-the-cat': guide(
    'hang',
    'Advanced hanging shoulder mobility and trunk control.',
    'Move slowly through a controlled inversion on secure rings or a bar, then return without dropping.',
    'Practise tuck hangs and partial ranges first.',
    'Use a pain-free shoulder range only.',
    'This is advanced; use a secure setup and coach oversight.'
  ),
  'pelvic-peel': guide(
    'hinge',
    'Glute bridge strength and spinal control.',
    'Lie on the back with knees bent, press through the feet, and lift the hips until the trunk and thighs form a line.',
    'Use a smaller range.',
    'Do not finish by arching the lower back.'
  ),
  'single-leg-pelvic-peel': guide(
    'hinge',
    'Single-leg glute bridge strength.',
    'Lift one foot, keep the pelvis level, and raise the hips using the planted leg.',
    'Use both legs or keep the range small.',
    'Both hip bones remain level.'
  ),
  'bridge-kick': guide(
    'hinge',
    'Bridge variation that adds single-leg control.',
    'Hold a bridge and extend one leg without dropping or rotating the hips.',
    'Keep both feet on the floor.',
    'The pelvis stays level while the leg moves.'
  ),
  'single-leg-reverse-bridge': guide(
    'hinge',
    'Posterior-chain hold with one-leg emphasis.',
    'Lift the hips into a reverse bridge, then keep one leg active while holding a straight line.',
    'Use both legs or bend the knees.',
    'Use a pain-free shoulder position.'
  ),
  'reverse-plank-bridge': guide(
    'hinge',
    'Posterior-chain and shoulder-extension strength.',
    'Sit with the hands behind the body and lift the hips into a straight line.',
    'Bend the knees into a tabletop bridge.',
    'Use a pain-free shoulder position.'
  ),
  pike: guide(
    'core',
    'Trunk compression and hamstring control.',
    'Fold from the hips or hold the programmed pike position while keeping the spine long.',
    'Bend the knees or reduce the range.',
    'Avoid forcing the lower back to round aggressively.'
  ),
  planche: guide(
    'core',
    'Straight-arm pushing strength and trunk tension.',
    'From a high plank, lean the shoulders forward while keeping the elbows locked and the body braced.',
    'Use elevated hands or a smaller lean.',
    'Stop if the wrists or front of the shoulders become painful.'
  ),
  'elbow-bridge': guide(
    'core',
    'Basic anti-extension trunk strength.',
    'Support the body on forearms and toes while squeezing the glutes and abdomen.',
    'Use the knees or an elevated surface.',
    'End the set before the lower back sags.'
  ),
  'hollow-body-hold': guide(
    'core',
    'Whole-body tension for advanced calisthenics.',
    'Press the lower back into the floor and lift the shoulders and legs.',
    'Bend the knees and keep the arms forward.',
    'The lower back does not lift.'
  ),
  'hollow-body-rocker': guide(
    'core',
    'Dynamic hollow-body trunk control.',
    'Hold a hollow position and rock slightly while keeping the ribs and pelvis locked together.',
    'Use a static hollow hold with bent knees.',
    'Stop when the lower back lifts from the floor.'
  ),
  'hanging-leg-raise': guide(
    'core',
    'Trunk control from a hanging position.',
    'From an active hang, lift the legs without swinging and lower slowly.',
    'Use hanging knee raises or a captain chair.',
    'Begin the movement with the pelvis, not momentum.'
  ),
  'hanging-reverse-curl': guide(
    'core',
    'Hanging trunk flexion with extra pelvic control.',
    'From an active hang, curl the pelvis upward and lower without swinging.',
    'Use hanging knee raises.',
    'Keep the shoulders active and the descent slow.'
  ),
  'knee-tuck-extension': guide(
    'core',
    'Core compression and extension control.',
    'Tuck the knees in, extend under control, and keep the trunk braced.',
    'Shorten the extension or keep the feet higher.',
    'Do not let the lower back collapse.'
  ),
  'dragon-flag': guide(
    'core',
    'Advanced anti-extension strength.',
    'Anchor the upper body, raise the hips, and lower the trunk and legs together through a controlled range.',
    'Bend the knees or shorten the range.',
    'Do not hinge sharply at the hips.'
  ),
  'flutter-up': guide(
    'core',
    'Low-abdominal endurance and leg-control drill.',
    'Keep the trunk braced while the legs move in a controlled flutter or raise pattern.',
    'Bend the knees or keep the legs higher.',
    'The lower back stays controlled.'
  ),
  'squat-jump': guide(
    'jump',
    'Lower-body power with controlled landings.',
    'Dip into a shallow squat, jump vertically, and land quietly before resetting.',
    'Use a fast calf raise or small hop.',
    'Stop when jump height or landing quality drops.'
  ),
  'x-jack': guide(
    'jump',
    'Jumping-jack conditioning with wider arm and leg action.',
    'Jump the feet out and in while moving the arms in a controlled rhythm.',
    'Step one foot at a time.',
    'Land softly and keep the knees tracking with the toes.'
  ),
  burpee: guide(
    'burpee',
    'Whole-body conditioning through floor transitions.',
    'Squat to the floor, move to a plank, return the feet forward, and stand or jump.',
    'Step instead of jumping and omit the push-up.',
    'Choose a pace that preserves trunk control.'
  ),
  'backward-burpee': guide(
    'burpee',
    'Burpee variation that moves through a controlled roll or backward transition.',
    'Move through each position deliberately and stand back up without rushing the spine or neck.',
    'Use a step-back burpee.',
    'Keep the transition smooth and pain-free.'
  ),
  'single-leg-burpee': guide(
    'burpee',
    'Advanced burpee variation with one-leg loading.',
    'Perform the burpee pattern while emphasizing one working leg and keeping the landing controlled.',
    'Use a normal burpee or step-back burpee.',
    'Stop if the working knee collapses inward.'
  ),
  'tuck-jump-burpee': guide(
    'burpee',
    'High-intensity burpee with an explosive tuck jump.',
    'Complete a burpee and finish with a controlled tuck jump.',
    'Use a normal jump.',
    'Use low repetitions and stop when landings become loud.'
  ),
  'burpee-to-pull-up': guide(
    'burpee',
    'Conditioning combined with vertical pulling.',
    'Complete a burpee beneath a bar, reach the bar safely, and perform one strict or assisted pull-up.',
    'Step onto a box and use an assisted pull-up.',
    'The bar height and landing area must be safe.'
  ),
  'burpee-to-chin-up': guide(
    'burpee',
    'Conditioning combined with an underhand vertical pull.',
    'Complete a burpee beneath a bar, reach the bar safely, and perform one strict or assisted chin-up.',
    'Step onto a box and use an assisted chin-up.',
    'Do not jump to a bar you cannot reach safely.'
  ),
  'mountain-climber': guide(
    'crawl',
    'Conditioning while maintaining plank control.',
    'From a high plank, alternate knee drives without bouncing the hips.',
    'Slow the pace or elevate the hands.',
    'Speed never exceeds control.'
  ),
  'dragon-walk': guide(
    'crawl',
    'Advanced crawling pattern with trunk and shoulder demand.',
    'Travel close to the floor with controlled opposite-side hand and foot movement.',
    'Use a bear crawl or shorter distance.',
    'Avoid twisting or rushing.'
  ),
  'handstand-walk': guide(
    'handstand',
    'Advanced overhead support and balance skill.',
    'Use a controlled wall-supported entry or shoulder shift before attempting freestanding steps.',
    'Practise wall handstand holds or pike holds.',
    'Practise in a clear space and learn a safe exit first.',
    'This is advanced; use coach supervision if the trainee is not already competent.'
  ),
  run: guide(
    'run',
    'Steady aerobic conditioning.',
    'Run or run-walk at the programmed effort while keeping the pace repeatable.',
    'Use brisk walking intervals.',
    'The pace should allow controlled breathing unless intervals are programmed.'
  ),
  'brisk-walk': guide(
    'run',
    'Low-impact aerobic work for base conditioning.',
    'Walk at a pace that raises breathing while still allowing short sentences.',
    'Slow down or use shorter intervals.',
    'Stop for chest pain, dizziness, or unusual symptoms.'
  ),
  'comfortable-walk': guide(
    'run',
    'Easy aerobic movement for recovery and consistency.',
    'Walk at a comfortable pace and keep the effort conversational.',
    'Use shorter walks or break the time into smaller blocks.',
    'The session should feel easy enough to repeat.'
  ),
  'easy-run-or-run-walk': guide(
    'run',
    'Aerobic running or run-walk conditioning.',
    'Use a pace that stays controlled and repeatable for the programmed time.',
    'Alternate short jogs with walking.',
    'Keep the effort below an all-out pace.'
  ),
  'long-easy-run-or-run-walk': guide(
    'run',
    'Long easy aerobic work.',
    'Use a conversational run or run-walk pace for the programmed duration.',
    'Use longer walk breaks or shorten the run.',
    'Finish with breathing and stride still under control.'
  ),
  'running-interval': guide(
    'run',
    'Controlled hard running intervals.',
    'Run the work interval at a hard but repeatable pace, then recover easily before the next repeat.',
    'Shorten the hard interval or use brisk walking.',
    'The final interval should still be controlled.'
  ),
  'dead-bug': guide(
    'core',
    'Trunk control while the limbs move.',
    'Lie on the back with hips and knees bent, then extend opposite arm and leg without lifting the lower back.',
    'Move one limb at a time.',
    'Exhale and keep the ribs controlled.'
  ),
  'front-plank': guide(
    'core',
    'Basic anti-extension trunk strength.',
    'Support the body on forearms and toes while squeezing the glutes and abdomen.',
    'Use the knees or an elevated surface.',
    'End the set before the lower back sags.'
  ),
  'side-plank': guide(
    'core',
    'Lateral trunk and shoulder stability.',
    'Support the body on one forearm and the side of the foot while keeping a straight line.',
    'Bend the lower knee.',
    'Keep the shoulder away from the ear.'
  ),
  'hip-hinge-drill': guide(
    'hinge',
    'Hip-hinge practice without rounding the back.',
    'Stand a short distance from a wall and push the hips backward until they touch it, then return by squeezing the glutes.',
    'Stand closer to the wall.',
    'The spine stays long and the shins remain nearly vertical.'
  ),
  'glute-bridge': guide(
    'hinge',
    'Glute strength and hip-extension practice.',
    'Lie on the back with knees bent, press through the feet, and lift the hips until the trunk and thighs form a line.',
    'Use a smaller range.',
    'Do not finish by arching the lower back.'
  ),
  'single-leg-glute-bridge': guide(
    'hinge',
    'Unilateral glute and hip-extension strength.',
    'Lift one foot, keep the pelvis level, and raise the hips using the planted leg.',
    'Use both legs.',
    'Both hip bones remain level.'
  ),
  'hamstring-walkout': guide(
    'hinge',
    'Hamstring strength without weights.',
    'Begin in a bridge, take small heel steps away from the hips, then walk back while keeping the hips lifted.',
    'Use fewer steps.',
    'Keep the movement slow and the pelvis controlled.'
  ),
  'supported-split-squat': guide(
    'lunge',
    'Split-stance balance and leg control.',
    'Take a staggered stance, hold stable support, lower mostly straight down, then stand through the front foot.',
    'Shorten the range.',
    'The front foot remains planted.'
  ),
  'reverse-lunge': guide(
    'lunge',
    'One-leg strength with a stable return.',
    'Step back, lower both knees under control, then drive through the front leg to stand.',
    'Hold support or use a shorter step.',
    'Keep most pressure through the front foot.'
  ),
  'lateral-lunge': guide(
    'lunge',
    'Leg strength in the side-to-side plane.',
    'Step wide, sit the hips toward the stepping side, keep the other leg long, and return to centre.',
    'Reduce step width and depth.',
    'The planted foot stays flat.'
  ),
  'walking-lunge': guide(
    'lunge',
    'Repeatable lunge endurance for conditioning.',
    'Step forward into each lunge, stand tall, then continue into the next controlled step.',
    'Use reverse lunges or shorten the stride.',
    'Land quietly and control the forward knee.'
  ),
  'rear-foot-elevated-split-squat': guide(
    'lunge',
    'Increased unilateral leg loading.',
    'Place the rear foot on a low support, lower through the front leg, and stand without bouncing off the rear leg.',
    'Keep the rear foot on the floor.',
    'The front leg performs most of the work.'
  ),
  'assisted-single-leg-squat-to-box': guide(
    'squat',
    'Single-leg strength with a controlled target.',
    'Stand on one leg in front of a box or chair, use light support, sit back to the target, and stand with the working leg.',
    'Use a higher target and more hand assistance.',
    'The working knee remains aligned over the foot.'
  ),
  'body-row': guide(
    'row',
    'Horizontal pulling strength with a rigid body line.',
    'Hang beneath a secure bar or straps and pull the chest toward the hands while keeping the body braced.',
    'Stand more upright or bend the knees.',
    'Finish by drawing the shoulder blades back, not by jutting the chin.'
  ),
  'archer-row': guide(
    'row',
    'Side-shifted body row for unilateral pulling strength.',
    'Row toward one hand while the opposite arm remains more extended.',
    'Use a more upright body angle.',
    'Resist trunk rotation.'
  ),
  'one-arm-body-row-progression': guide(
    'row',
    'Unilateral body-row progression.',
    'Pull with one arm while keeping the shoulders and hips square.',
    'Use two hands with one hand providing light assistance.',
    'Use a secure setup and stop before grip failure.'
  ),
  'scapular-pull': guide(
    'hang',
    'Active shoulder control while hanging.',
    'From a straight-arm hang, draw the shoulders down without bending the elbows, then return slowly.',
    'Keep the feet partly supported.',
    'Do not shrug or swing.'
  ),
  'hanging-knee-raise': guide(
    'core',
    'Trunk control from a hanging position.',
    'From an active hang, lift the knees without swinging and lower slowly.',
    'Use a captain chair or a smaller range.',
    'Begin the movement with the pelvis, not momentum.'
  ),
  'hollow-hold': guide(
    'core',
    'Whole-body tension for calisthenics.',
    'Press the lower back into the floor and lift the shoulders and legs.',
    'Bend the knees and keep the arms forward.',
    'The lower back does not lift.'
  ),
  'step-back-burpee': guide(
    'burpee',
    'Low-impact burpee pattern practice.',
    'Place the hands down, step to a plank, step forward, and stand.',
    'Use an elevated surface.',
    'Move through clear positions rather than collapsing to the floor.'
  ),
  'bear-crawl': guide(
    'crawl',
    'Shoulder stability, trunk control, and coordination.',
    'Move on hands and feet with the knees hovering close to the floor.',
    'Use shorter distances or allow the knees to touch between steps.',
    'Take small steps and keep the back level.'
  ),
  'skater-bound': guide(
    'jump',
    'Lateral power and landing control.',
    'Jump sideways from one leg to the other and absorb the landing before repeating.',
    'Use a skater step.',
    'The landing knee tracks over the toes.'
  ),
  'marching-mountain-climber': guide(
    'crawl',
    'Introductory loaded trunk movement.',
    'From an incline or floor plank, alternate bringing one knee forward at a controlled pace.',
    'Use a higher support.',
    'Keep the pelvis quiet.'
  ),
  'plyometric-push-up-or-fast-incline-push-up': guide(
    'push',
    'Upper-body power scaled to the trainee.',
    'Press explosively while maintaining a strong plank, using the incline version if the floor variation is not controlled.',
    'Use fast non-airborne incline push-ups.',
    'Every landing or hand contact stays quiet and stable.'
  ),
  'hanging-knee-or-leg-raise': guide(
    'core',
    'Hanging trunk control from a secure bar.',
    'From an active hang, lift the knees or legs without swinging and lower slowly.',
    'Use hanging knee raises or a captain chair.',
    'Begin the movement with the pelvis, not momentum.'
  ),
  'pistol-squat-progression': guide(
    'squat',
    'High-level single-leg strength and mobility.',
    'Lower on one leg only through a range that can be reversed without collapsing.',
    'Hold support or squat to a box.',
    'Keep the heel down and the pelvis controlled.'
  ),
  'rest-between-rounds': guide(
    'default',
    'Planned recovery so the next round stays repeatable.',
    'Rest for the programmed time, breathe through the nose if possible, and restart only when form can be maintained.',
    'Take the longer end of the rest range.',
    'The next round should not begin with rushed or sloppy movement.'
  ),
  'recovery-check': guide(
    'default',
    'Simple readiness check for pain and unusual symptoms.',
    'Use the rest day to notice soreness, joint pain, dizziness, or unusual fatigue before returning to training.',
    'Choose gentle walking only.',
    'Do not train hard through sharp pain, chest pain, dizziness, or worsening joint discomfort.'
  ),
  'wall-handstand-hold-or-shoulder-shift': guide(
    'handstand',
    'Overhead support strength and inversion confidence.',
    'Use a controlled wall entry and hold a stacked position, or shift weight gently from hand to hand.',
    'Use a pike hold with the feet on the floor.',
    'Practise in a clear space and learn a safe exit first.'
  ),
  'planche-lean': guide(
    'core',
    'Straight-arm pushing strength.',
    'From a high plank, lean the shoulders forward while keeping the feet on the floor and elbows locked.',
    'Use elevated hands or a small lean.',
    'Stop if the wrists or front of the shoulders become painful.'
  ),
  'one-arm-push-up-progression': guide(
    'push',
    'Progression toward high relative pressing strength.',
    'Use one working hand and a wide foot stance, lowering only through a range you can control.',
    'Use an elevated surface or fingertip assistance.',
    'Progress gradually and do not force depth.'
  ),
  'tuck-front-lever-hold': guide(
    'hang',
    'Straight-arm pulling and trunk tension.',
    'From a hang, draw the knees in and lift the hips until the torso approaches horizontal.',
    'Use tuck raises or very short holds.',
    'Keep the shoulders active and do not drop suddenly.'
  ),
  'assisted-one-arm-chin-up': guide(
    'pull',
    'Assisted high-level one-arm pulling strength.',
    'Pull mainly with one arm while the other hand assists through a strap, band, or lower grip.',
    'Use standard chin-ups and slow negatives.',
    'Avoid uncontrolled one-arm negatives, which can overload the elbow.'
  ),
  'l-sit-support-progression': guide(
    'core',
    'Compression and straight-arm support strength.',
    'Press down into parallel handles and lift the knees or legs in front.',
    'Use a tuck hold with one foot touching lightly.',
    'Keep the shoulders depressed and elbows locked.'
  ),
  'dragon-flag-eccentric': guide(
    'core',
    'Advanced anti-extension strength.',
    'Anchor the upper body, raise the hips, and lower the trunk and legs together through a controlled range.',
    'Bend the knees or shorten the range.',
    'Do not hinge sharply at the hips.'
  ),
  'burpee-pull-up': guide(
    'burpee',
    'Conditioning combined with vertical pulling.',
    'Complete a burpee beneath a bar, reach the bar safely, and perform one strict or assisted pull-up.',
    'Step onto a box and use an assisted pull-up.',
    'The bar height and landing area must be safe.'
  ),
  'forward-hinge': guide(
    'hinge',
    'Hip-hinge control without external weight.',
    'Push the hips backward, keep the spine long, and return by squeezing the glutes.',
    'Shorten the range or use a wall hinge drill.',
    'The spine remains long and the shins stay nearly vertical.'
  ),
  'pigeon-peel': guide(
    'hinge',
    'Hip mobility and glute control.',
    'Move through a comfortable hip range with slow breathing and no forcing.',
    'Reduce the range or use a supported position.',
    'Stop if the hip or knee feels pinched.'
  ),
  'butterfly-peel': guide(
    'hinge',
    'Hip mobility and controlled external rotation.',
    'Move through a comfortable butterfly position with steady breathing and controlled posture.',
    'Sit on a raised surface or reduce the range.',
    'Do not force the knees downward.'
  ),
  'squat-to-l-sit': guide(
    'core',
    'Advanced transition from leg work into compression support.',
    'Move from the squat into a controlled L-sit or tuck support with locked elbows.',
    'Use a tuck support or separate the squat and hold.',
    'Keep the shoulders depressed and the elbows locked.'
  ),
};

const onRampWorkouts = [
  workout('Day 1 - Squat, Push, and Trunk', 'Two easy rounds plus a brisk walk.', 18, [
    ['Chair Squat', '2 rounds x 8 reps'],
    ['Wall Push-Up', '2 rounds x 8 reps'],
    ['Dead Bug', '2 rounds x 5 reps per side'],
    ['Brisk Walk', '8 to 15 minutes'],
  ]),
  workout('Day 2 - Easy Movement', 'Walking, hinge practice, and supported split stance.', 25, [
    ['Comfortable Walk', '15 to 25 minutes'],
    ['Hip-Hinge Drill', '2 x 8 reps'],
    ['Supported Split Squat', '2 x 5 reps per side'],
  ]),
  workout('Day 3 - Pulling Introduction', 'Two rounds of pulling, bridging, trunk, and plank work.', 20, [
    ['Body Row', '2 rounds x 6 reps'],
    ['Glute Bridge', '2 rounds x 10 reps'],
    ['Marching Mountain Climber', '2 rounds x 6 reps per side'],
    ['Front Plank', '2 rounds x 15 to 20 seconds'],
  ]),
  workout('Day 4 - Rest or Gentle Walking', 'No hard training.', 15, [
    ['Comfortable Walk', 'Optional 10 to 20 minutes'],
    ['Recovery Check', 'Stop if pain or unusual symptoms appear'],
  ]),
  workout('Day 5 - Full-Body Practice', 'Three easy rounds with repeatable form.', 24, [
    ['Chair Squat', '3 rounds x 8 reps'],
    ['Incline Push-Up', '3 rounds x 6 reps'],
    ['Body Row', '3 rounds x 6 reps'],
    ['Step-Back Burpee', '3 rounds x 4 reps'],
    ['Rest Between Rounds', '60 to 90 seconds'],
  ]),
  workout('Day 6 - Low-Intensity Conditioning', 'Brisk walk plus optional faster walking intervals.', 30, [
    ['Brisk Walk', '20 to 30 minutes'],
    ['Running Interval', 'Optional 4 x 20 seconds faster walking with 70 seconds easy'],
  ]),
  workout('Day 7 - Readiness Review', 'Repeat the Stage 1 entry check.', 18, [
    ['Chair Squat', '10 controlled reps'],
    ['Incline Push-Up', '8 controlled reps'],
    ['Front Plank', '20 seconds'],
    ['Reverse Lunge', '20 alternating reps with support if needed'],
    ['Brisk Walk', '10 minutes without unusual symptoms'],
  ]),
] satisfies WorkoutEntry[];

const foundationWorkouts = [
  workout('Session A - Foundation Strength', 'Squat, push, pull, bridge, and plank.', 35, [
    ['Bodyweight Squat', '2-3 x 8-15 reps'],
    ['Incline or Floor Push-Up', '2-3 x 6-12 reps'],
    ['Body Row', '2-3 x 6-12 reps'],
    ['Glute Bridge', '2-3 x 10-15 reps'],
    ['Front Plank', '2-3 x 20-40 seconds'],
  ]),
  workout('Session B - Foundation Control', 'Reverse lunge, overhead push, assisted pull, hinge, and side plank.', 35, [
    ['Reverse Lunge', '2-3 x 6-10 reps per side'],
    ['Pike Push-Up', '2-3 x 5-10 reps'],
    ['Chin-Up Assistance or Scapular Pull', '2-3 x 4-8 reps'],
    ['Hip-Hinge Drill', '2-3 x 10-15 reps'],
    ['Side Plank', '2-3 x 15-30 seconds per side'],
  ]),
  workout('Session C - Controlled Circuit', 'Three to five rounds at a controlled pace.', 30, [
    ['Step-Back Burpee', '3-5 rounds x 5-8 reps'],
    ['Lateral Lunge', '3-5 rounds x 6 reps per side'],
    ['Mountain Climber', '3-5 rounds x 10 reps per side'],
    ['Body Row', '3-5 rounds x 6-10 reps'],
    ['Rest Between Rounds', '60 to 90 seconds'],
  ]),
] satisfies WorkoutEntry[];

const developmentWorkouts = [
  workout('Day 1 - Lower-Body Strength', 'Unilateral leg strength, hamstrings, glutes, and trunk.', 42, [
    ['Rear-Foot-Elevated Split Squat', '4 x 6-10 reps per side'],
    ['Assisted Single-Leg Squat to Box', '3 x 5-8 reps per side'],
    ['Hamstring Walkout', '3 x 6-10 reps'],
    ['Single-Leg Glute Bridge', '3 x 8-12 reps per side'],
    ['Side Plank', '3 x 20-40 seconds per side'],
  ]),
  workout('Day 2 - Upper-Body Strength', 'Vertical pull, close push, row, pike push, and hanging trunk work.', 42, [
    ['Pull-Up or Chin-Up Progression', '4 x 4-8 reps'],
    ['Close-Grip Push-Up', '4 x 6-12 reps'],
    ['Archer Row', '3 x 5-8 reps per side'],
    ['Pike Push-Up', '3 x 6-10 reps'],
    ['Hanging Knee Raise', '3 x 6-12 reps'],
  ]),
  workout('Day 4 - Power and Movement', 'Explosive work with full recovery between sets.', 36, [
    ['Squat Jump', '5 x 3-5 reps'],
    ['Plyometric Push-Up or Fast Incline Push-Up', '5 x 3-5 reps'],
    ['Skater Bound', '4 x 5 reps per side'],
    ['Bear Crawl', '4 x 10-20 metres'],
    ['Hollow Hold', '3 x 15-30 seconds'],
  ]),
  workout('Day 5 - Conditioning', 'Four to six repeatable rounds.', 34, [
    ['Burpee', '4-6 rounds x 6 reps'],
    ['Reverse Lunge', '4-6 rounds x 8 reps per side'],
    ['Mountain Climber', '4-6 rounds x 12 reps per side'],
    ['Body Row', '4-6 rounds x 8 reps'],
    ['Rest Between Rounds', '60 to 90 seconds'],
  ]),
] satisfies WorkoutEntry[];

const performanceWorkouts = [
  workout('Day 1 - Handstand and Push', 'Advanced skill first, then pressing strength.', 45, [
    ['Wall Handstand Hold or Shoulder Shift', '5 x 15-30 seconds'],
    ['Planche Lean', '4 x 8-15 seconds'],
    ['One-Arm Push-Up Progression', '4 x 3-6 reps per side'],
    ['Archer Push-Up', '3 x 5-8 reps per side'],
    ['Pike Push-Up', '3 x 6-10 reps'],
  ]),
  workout('Day 2 - Pulling Strength', 'Lever, one-arm pulling, rows, pull-ups, and hanging trunk work.', 45, [
    ['Tuck Front-Lever Hold', '5 x 6-12 seconds'],
    ['Assisted One-Arm Chin-Up', '4 x 2-5 reps per side'],
    ['One-Arm Body Row Progression', '4 x 4-8 reps per side'],
    ['Pull-Up', '3 x 5-10 reps'],
    ['Hanging Knee or Leg Raise', '3 x 6-12 reps'],
  ]),
  workout('Day 4 - Legs and Power', 'Single-leg strength and controlled explosive work.', 42, [
    ['Pistol Squat Progression', '5 x 3-6 reps per side'],
    ['Rear-Foot-Elevated Split Squat', '3 x 8-12 reps per side'],
    ['Hamstring Walkout', '3 x 8-12 reps'],
    ['Squat Jump', '5 x 3 reps'],
    ['Skater Bound', '4 x 5 reps per side'],
  ]),
  workout('Day 5 - Trunk and Mixed Conditioning', 'Compression, advanced trunk strength, pull conditioning, and crawling.', 40, [
    ['L-Sit Support Progression', '5 x 8-20 seconds'],
    ['Dragon-Flag Eccentric', '4 x 2-5 reps'],
    ['Hollow Hold', '3 x 20-40 seconds'],
    ['Burpee Pull-Up', '5 x 3-5 reps'],
    ['Bear Crawl', '4 x 15-25 metres'],
  ]),
] satisfies WorkoutEntry[];

const hybridRacePrepWorkouts = [
  workout('Day 1 - Easy Run Plus Strength', 'Aerobic base plus bodyweight strength.', 48, [
    ['Easy Run or Run-Walk', '25-45 minutes'],
    ['Rear-Foot-Elevated Split Squat', '3 x 8 reps per side'],
    ['Push-Up', '3 x 8-15 reps'],
    ['Body Row', '3 x 8-15 reps'],
    ['Front Plank', '3 x 30-45 seconds'],
  ]),
  workout('Day 2 - Running Intervals', 'Controlled hard repeats with easy recovery.', 36, [
    ['Running Interval', 'Weeks 1-2: 6 x 2 minutes hard with 2 minutes easy'],
    ['Running Interval', 'Weeks 3-4: 5 x 3 minutes hard with 2 minutes easy'],
    ['Running Interval', 'Week 5: 4 x 5 minutes near race effort with 2 minutes easy'],
    ['Running Interval', 'Week 6: 4 x 2 minutes controlled with full easy recovery'],
  ]),
  workout('Day 4 - Hybrid Station Circuit', 'Three to six repeatable rounds.', 45, [
    ['Run', '400 metres or 2-3 minutes'],
    ['Burpee', '8 reps'],
    ['Walking Lunge', '16 total steps'],
    ['Bear Crawl', '15-20 metres'],
    ['Push-Up', '8-15 reps'],
    ['Body Row', '8-15 reps'],
    ['Rest Between Rounds', '90 seconds'],
  ]),
  workout('Day 6 - Long Easy Run', 'Easy aerobic progression for six weeks.', 55, [
    ['Long Easy Run or Run-Walk', 'Week 1: 35 minutes'],
    ['Long Easy Run or Run-Walk', 'Week 2: 40 minutes'],
    ['Long Easy Run or Run-Walk', 'Week 3: 45 minutes'],
    ['Long Easy Run or Run-Walk', 'Week 4: 50 minutes'],
    ['Long Easy Run or Run-Walk', 'Week 5: 55-60 minutes'],
    ['Long Easy Run or Run-Walk', 'Week 6: 30-40 minutes easy'],
  ]),
] satisfies WorkoutEntry[];
const programmeCatalog = [
  programme('stage-0-on-ramp', 'Seven-Day On-Ramp', 'Stage 0', 'Movement practice for a new or returning trainee.', onRampWorkouts),
  programme('stage-1-foundation', 'Foundation Program', 'Stage 1', 'Three full-body sessions per week for basic strength and control.', foundationWorkouts),
  programme('stage-2-development', 'Development Program', 'Stage 2', 'Four weekly sessions for unilateral strength, power, and conditioning.', developmentWorkouts),
  programme('stage-3-performance', 'Performance Program', 'Stage 3', 'Advanced calisthenics strength, skill, and mixed conditioning.', performanceWorkouts),
  programme('hybrid-race-prep', 'Hybrid Race Prep', 'Race Prep', 'Generic hybrid fitness race preparation without event-brand affiliation.', hybridRacePrepWorkouts),
] satisfies CoachProgramme[];

export const coachConfig = {
  brandName: 'Zero to Hero Coaching',
  trainerName: 'Coach Arno',
  headline: programmeCatalog[0].title,
  subheadline: programmeCatalog[0].subtitle,
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
  programmes: programmeCatalog,
  programme: programmeCatalog[0].days,
};

export type CoachConfig = typeof coachConfig;

function programme(id: string, title: string, level: string, subtitle: string, workouts: readonly WorkoutEntry[]): CoachProgramme {
  return {
    id,
    title,
    level,
    subtitle,
    durationLabel: `${workouts.length} workouts`,
    days: workouts.map((entry, index) => buildDay(id, index + 1, entry)),
  };
}

function workout(title: string, focus: string, durationMinutes: number, exercises: readonly ExerciseEntry[]): WorkoutEntry {
  return { title, focus, durationMinutes, exercises };
}

function buildDay(programmeId: string, day: number, entry: WorkoutEntry): ProgrammeDay {
  return {
    day,
    title: entry.title,
    focus: entry.focus,
    durationMinutes: entry.durationMinutes,
    exercises: entry.exercises.map(([name, target, restSeconds], index) => {
      const exerciseGuide = getExerciseGuide(name);

      return {
        id: `${programmeId}-d${day}-${index + 1}-${slug(name)}`,
        name,
        target,
        description: exerciseGuide.description,
        visualKind: exerciseGuide.visualKind,
        restSeconds: restSeconds ?? inferRestSeconds(target),
        instructions: [
          exerciseGuide.method,
          `Easier: ${exerciseGuide.easier}`,
          `Key standard: ${exerciseGuide.keyStandard}`,
        ],
        coachNote: exerciseGuide.caution ?? 'Ask your trainer for the right variation if form starts to break.',
      };
    }),
  };
}

function getExerciseGuide(name: string): ExerciseGuide {
  const key = slug(name)
    .replace(/-left$/, '')
    .replace(/-right$/, '');

  const directGuide = exerciseGuides[key];
  if (directGuide) {
    return directGuide;
  }

  if (key.includes('pigeon-peel') && key.includes('butterfly-peel')) {
    return guide(
      'hinge',
      'Hip mobility pair for controlled range and recovery.',
      'Move through each position slowly, breathe steadily, and stay inside a comfortable range.',
      'Use a supported position or reduce the range.',
      'Do not force the hip or knee into a painful position.'
    );
  }

  if (key.includes('push-up')) {
    return exerciseGuides['standard-push-up'];
  }

  if (key.includes('pull-up')) {
    return exerciseGuides['pull-up'];
  }

  if (key.includes('chin-up')) {
    return exerciseGuides['chin-up'];
  }

  if (key.includes('inverted-row') || key.includes('body-row') || key.includes('row')) {
    return exerciseGuides['inverted-bodyweight-row'];
  }

  if (key.includes('lunge')) {
    return exerciseGuides['back-lunge'];
  }

  if (key.includes('squat')) {
    return exerciseGuides.squat;
  }

  if (key.includes('bridge') || key.includes('peel')) {
    return exerciseGuides['pelvic-peel'];
  }

  if (key.includes('burpee')) {
    return exerciseGuides.burpee;
  }

  if (key.includes('jump') || key.includes('jack')) {
    return exerciseGuides['squat-jump'];
  }

  if (key.includes('hang') || key.includes('lever')) {
    return exerciseGuides['dead-hang'];
  }

  if (key.includes('plank') || key.includes('hollow') || key.includes('flag') || key.includes('raise') || key.includes('curl') || key.includes('tuck')) {
    return exerciseGuides['hollow-body-hold'];
  }

  return guide(
    'default',
    'Controlled bodyweight movement for the programmed target.',
    'Use the programmed target, move deliberately, and breathe through the repetition or hold.',
    'Reduce range, slow the tempo, or use support.',
    'Stop when technique changes, pain appears, or balance becomes unsafe.'
  );
}

function inferRestSeconds(target: string): number {
  if (target.includes('10 seconds rest')) {
    return 10;
  }

  if (target.includes('90 seconds') || target.includes('60 to 90 seconds') || target.includes('60-90 seconds')) {
    return 90;
  }

  if (target.includes('30-60 seconds') || target.includes('30 to 60 seconds')) {
    return 45;
  }

  if (target.includes('60 seconds') || target.includes('1:00') || target.includes('70 seconds')) {
    return 60;
  }

  if (target.includes('minutes') || target.includes('metres')) {
    return 45;
  }

  return 30;
}

function slug(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

