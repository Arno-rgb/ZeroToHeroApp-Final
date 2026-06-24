import React, { useEffect, useMemo, useState } from 'react';
import {
  FaArrowLeft,
  FaArrowRight,
  FaCalendarAlt,
  FaChartBar,
  FaCheck,
  FaDumbbell,
  FaFire,
  FaHome,
  FaPause,
  FaPlay,
  FaStar,
  FaTrophy,
  FaUser,
  FaWhatsapp,
} from 'react-icons/fa';
import { coachConfig, ProgrammeExercise } from '../coachConfig';

type View = 'today' | 'workout' | 'progress' | 'coach';

type DemoProgress = {
  completedExerciseIds: string[];
  completedDayIds: number[];
  programmeStartedAt: string;
};

type BeforeInstallPromptEvent = Event & {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed'; platform: string }>;
};

const storageKey = 'coach-demo-progress-v1';

const defaultProgress: DemoProgress = {
  completedExerciseIds: [],
  completedDayIds: [],
  programmeStartedAt: new Date().toISOString(),
};

export function CoachDemoApp(): React.JSX.Element {
  const [activeView, setActiveView] = useState<View>('today');
  const [selectedDay, setSelectedDay] = useState(1);
  const [activeExerciseId, setActiveExerciseId] = useState<string | null>(coachConfig.programme[0]?.exercises[0]?.id ?? null);
  const [progress, setProgress] = useState<DemoProgress>(() => loadProgress());
  const [installPrompt, setInstallPrompt] = useState<BeforeInstallPromptEvent | null>(null);
  const [remainingSeconds, setRemainingSeconds] = useState(coachConfig.programme[0]?.exercises[0]?.restSeconds ?? 0);
  const [timerRunning, setTimerRunning] = useState(false);

  const selectedProgrammeDay = coachConfig.programme.find(day => day.day === selectedDay) ?? coachConfig.programme[0];
  const activeExercise = selectedProgrammeDay.exercises.find(exercise => exercise.id === activeExerciseId) ?? selectedProgrammeDay.exercises[0];
  const activeExerciseIndex = selectedProgrammeDay.exercises.findIndex(exercise => exercise.id === activeExercise.id);
  const totalExerciseCount = coachConfig.programme.reduce((sum, day) => sum + day.exercises.length, 0);
  const completedExerciseCount = progress.completedExerciseIds.length;
  const completionPercent = Math.round((completedExerciseCount / totalExerciseCount) * 100);
  const todayPercent = Math.round(
    (selectedProgrammeDay.exercises.filter(exercise => progress.completedExerciseIds.includes(exercise.id)).length /
      selectedProgrammeDay.exercises.length) *
      100
  );
  const whatsappUrl = useMemo(() => {
    const message = encodeURIComponent(coachConfig.whatsappMessage);
    return `https://wa.me/${coachConfig.whatsappNumber}?text=${message}`;
  }, []);

  useEffect(() => {
    localStorage.setItem(storageKey, JSON.stringify(progress));
  }, [progress]);

  useEffect(() => {
    const handleBeforeInstallPrompt = (event: Event): void => {
      event.preventDefault();
      setInstallPrompt(event as BeforeInstallPromptEvent);
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    return () => window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
  }, []);

  useEffect(() => {
    const firstExercise = selectedProgrammeDay.exercises[0];
    if (!firstExercise) {
      return;
    }

    setActiveExerciseId(firstExercise.id);
    setRemainingSeconds(firstExercise.restSeconds);
    setTimerRunning(false);
  }, [selectedProgrammeDay.day, selectedProgrammeDay.exercises]);

  useEffect(() => {
    if (!activeExercise) {
      return;
    }

    setRemainingSeconds(activeExercise.restSeconds);
    setTimerRunning(false);
  }, [activeExercise?.id]);

  useEffect(() => {
    if (!timerRunning || remainingSeconds <= 0) {
      return;
    }

    const intervalId = window.setInterval(() => {
      setRemainingSeconds(seconds => Math.max(0, seconds - 1));
    }, 1000);

    return () => window.clearInterval(intervalId);
  }, [remainingSeconds, timerRunning]);

  const setExerciseComplete = (exercise: ProgrammeExercise): void => {
    setProgress(current => {
      const completedExerciseIds = current.completedExerciseIds.includes(exercise.id)
        ? current.completedExerciseIds
        : [...current.completedExerciseIds, exercise.id];
      const dayComplete = selectedProgrammeDay.exercises.every(dayExercise => completedExerciseIds.includes(dayExercise.id));
      const completedDayIds =
        dayComplete && !current.completedDayIds.includes(selectedProgrammeDay.day)
          ? [...current.completedDayIds, selectedProgrammeDay.day]
          : current.completedDayIds;

      return {
        ...current,
        completedExerciseIds,
        completedDayIds,
      };
    });
  };

  const startExercise = (exercise: ProgrammeExercise): void => {
    setActiveExerciseId(exercise.id);
    setRemainingSeconds(exercise.restSeconds);
    setTimerRunning(false);
    setActiveView('workout');
  };

  const completeSet = (): void => {
    setExerciseComplete(activeExercise);
    setRemainingSeconds(activeExercise.restSeconds);
    setTimerRunning(activeExercise.restSeconds > 0);
  };

  const goToNextExercise = (): void => {
    const nextExercise = selectedProgrammeDay.exercises[activeExerciseIndex + 1];
    if (nextExercise) {
      startExercise(nextExercise);
      return;
    }

    markDayComplete();
  };

  const markDayComplete = (): void => {
    setProgress(current => {
      const exerciseIds = selectedProgrammeDay.exercises.map(exercise => exercise.id);
      const completedExerciseIds = Array.from(new Set([...current.completedExerciseIds, ...exerciseIds]));
      const completedDayIds = current.completedDayIds.includes(selectedProgrammeDay.day)
        ? current.completedDayIds
        : [...current.completedDayIds, selectedProgrammeDay.day];

      return {
        ...current,
        completedExerciseIds,
        completedDayIds,
      };
    });
    setActiveView('progress');
  };

  const resetDemo = (): void => {
    const firstExercise = selectedProgrammeDay.exercises[0];
    setProgress({ ...defaultProgress, programmeStartedAt: new Date().toISOString() });
    setActiveExerciseId(firstExercise?.id ?? null);
    setRemainingSeconds(firstExercise?.restSeconds ?? 0);
    setTimerRunning(false);
  };

  const installApp = async (): Promise<void> => {
    if (!installPrompt) {
      setActiveView('coach');
      return;
    }

    await installPrompt.prompt();
    await installPrompt.userChoice;
    setInstallPrompt(null);
  };

  return (
    <main
      className="coach-app"
      style={
        {
          '--coach-primary': coachConfig.colors.primary,
          '--coach-accent': coachConfig.colors.accent,
        } as React.CSSProperties
      }
    >
      <section className="phone-frame" aria-label="Trainer client demo">
        <div className="status-bar" aria-hidden="true">
          <span>9:41</span>
          <span className="phone-indicators">●●● ▰</span>
        </div>
        <div className="dynamic-island" aria-hidden="true" />

        {activeView === 'workout' ? (
          <WorkoutView
            day={selectedProgrammeDay}
            exercise={activeExercise}
            exerciseIndex={activeExerciseIndex}
            remainingSeconds={remainingSeconds}
            timerRunning={timerRunning}
            onBack={() => setActiveView('today')}
            onCompleteSet={completeSet}
            onNextExercise={goToNextExercise}
            onToggleTimer={() => setTimerRunning(running => !running)}
          />
        ) : (
          <>
            <AppHeader activeView={activeView} installAvailable={Boolean(installPrompt)} onInstall={installApp} />

            {activeView === 'today' && (
              <TodayView
                day={selectedProgrammeDay}
                completionPercent={todayPercent}
                completedExerciseIds={progress.completedExerciseIds}
                onDaySelect={setSelectedDay}
                selectedDay={selectedDay}
                onStartExercise={startExercise}
                onStartWorkout={() => startExercise(selectedProgrammeDay.exercises[0])}
              />
            )}

            {activeView === 'progress' && (
              <ProgressView
                progress={progress}
                completionPercent={completionPercent}
                totalExerciseCount={totalExerciseCount}
                completedExerciseCount={completedExerciseCount}
                onReset={resetDemo}
              />
            )}

            {activeView === 'coach' && (
              <CoachView whatsappUrl={whatsappUrl} installPromptAvailable={Boolean(installPrompt)} onInstall={installApp} />
            )}
          </>
        )}

        <BottomNav activeView={activeView} onChange={setActiveView} />
      </section>
    </main>
  );
}

function AppHeader({
  activeView,
  installAvailable,
  onInstall,
}: {
  activeView: View;
  installAvailable: boolean;
  onInstall: () => void;
}): React.JSX.Element {
  if (activeView === 'progress') {
    return (
      <header className="simple-header">
        <span />
        <h1>Progress</h1>
        <FaTrophy aria-hidden="true" />
      </header>
    );
  }

  if (activeView === 'coach') {
    return (
      <header className="simple-header">
        <span />
        <h1>Profile</h1>
        <FaWhatsapp aria-hidden="true" />
      </header>
    );
  }

  return (
    <header className="coach-header">
      <div className="coach-brand-row">
        <img src={coachConfig.logoPath} alt={`${coachConfig.brandName} logo`} className="coach-logo" />
        <div>
          <p className="brand-mark">{coachConfig.brandName}</p>
          <p>Welcome back, Sam</p>
        </div>
      </div>
      <button className="avatar-button" type="button" onClick={onInstall} aria-label={installAvailable ? 'Install app' : 'Open install instructions'}>
        <img src={coachConfig.logoPath} alt="" />
      </button>
    </header>
  );
}

function TodayView({
  day,
  selectedDay,
  completionPercent,
  completedExerciseIds,
  onDaySelect,
  onStartExercise,
  onStartWorkout,
}: {
  day: (typeof coachConfig.programme)[number];
  selectedDay: number;
  completionPercent: number;
  completedExerciseIds: string[];
  onDaySelect: (day: number) => void;
  onStartExercise: (exercise: ProgrammeExercise) => void;
  onStartWorkout: () => void;
}): React.JSX.Element {
  return (
    <section className="screen-section today-screen">
      <p className="screen-subtitle">Ready to crush today?</p>

      <article className="workout-summary-card">
        <div className="summary-heading">
          <div>
            <h2>Today&apos;s Workout</h2>
            <p>{day.title}</p>
          </div>
          <span className="date-pill">
            <FaCalendarAlt aria-hidden="true" />
            Day {day.day}
          </span>
        </div>

        <div className="summary-body">
          <div className="summary-exercises">
            {day.exercises.map(exercise => {
              const completed = completedExerciseIds.includes(exercise.id);
              return (
                <button
                  className={`exercise-row ${completed ? 'complete' : ''}`}
                  type="button"
                  key={exercise.id}
                  onClick={() => onStartExercise(exercise)}
                >
                  <span className="exercise-icon">{getExerciseGlyph(exercise.name)}</span>
                  <span>
                    <strong>{exercise.name}</strong>
                    <small>{exercise.target}</small>
                  </span>
                  {completed && <FaCheck aria-label="Completed" />}
                </button>
              );
            })}
          </div>

          <div className="compact-ring" style={{ '--ring-value': `${completionPercent * 3.6}deg` } as React.CSSProperties}>
            <span>{completionPercent}%</span>
            <small>Workout Progress</small>
          </div>
        </div>

        <button type="button" className="primary-action" onClick={onStartWorkout}>
          Start Workout
          <FaArrowRight aria-hidden="true" />
        </button>
      </article>

      <nav className="day-strip" aria-label="Programme days">
        {coachConfig.programme.map(programmeDay => (
          <button
            key={programmeDay.day}
            type="button"
            className={programmeDay.day === selectedDay ? 'active' : ''}
            onClick={() => onDaySelect(programmeDay.day)}
          >
            D{programmeDay.day}
          </button>
        ))}
      </nav>

      <article className="daily-tip-card">
        <div>
          <h3>
            <FaFire aria-hidden="true" />
            Daily Tip
          </h3>
          <p>{day.focus}</p>
        </div>
        <div className="mountain-mark" aria-hidden="true">
          <span />
          <span />
          <span />
        </div>
      </article>
    </section>
  );
}

function WorkoutView({
  day,
  exercise,
  exerciseIndex,
  remainingSeconds,
  timerRunning,
  onBack,
  onCompleteSet,
  onNextExercise,
  onToggleTimer,
}: {
  day: (typeof coachConfig.programme)[number];
  exercise: ProgrammeExercise;
  exerciseIndex: number;
  remainingSeconds: number;
  timerRunning: boolean;
  onBack: () => void;
  onCompleteSet: () => void;
  onNextExercise: () => void;
  onToggleTimer: () => void;
}): React.JSX.Element {
  const timerPercent = exercise.restSeconds > 0 ? Math.round(((exercise.restSeconds - remainingSeconds) / exercise.restSeconds) * 100) : 100;

  return (
    <section className="screen-section workout-screen">
      <header className="workout-header">
        <button type="button" className="icon-button" onClick={onBack} aria-label="Back to today">
          <FaArrowLeft aria-hidden="true" />
        </button>
        <h1>Workout</h1>
        <span className="header-dots" aria-hidden="true">
          •••
        </span>
      </header>

      <div className="set-progress">
        <strong>
          {exerciseIndex + 1} of {day.exercises.length}
        </strong>
        <div className="segment-row" aria-hidden="true">
          {day.exercises.map((item, index) => (
            <span className={index <= exerciseIndex ? 'active' : ''} key={item.id} />
          ))}
        </div>
      </div>

      <article className="active-workout-card">
        <div className="active-exercise-heading">
          <span className="large-exercise-icon">{getExerciseGlyph(exercise.name)}</span>
          <div>
            <h2>{exercise.name}</h2>
            <p>{exercise.target}</p>
          </div>
        </div>

        <div className="rep-panel">
          <span>
            <small>Set</small>
            <strong>1 of {getSetCount(exercise.target)}</strong>
          </span>
          <span>
            <small>Target</small>
            <strong>{getRepTarget(exercise.target)}</strong>
          </span>
        </div>

        <div className="timer-ring" style={{ '--ring-value': `${timerPercent * 3.6}deg` } as React.CSSProperties}>
          <div>
            <strong>{formatSeconds(remainingSeconds)}</strong>
            <span>{remainingSeconds === 0 ? 'Rest Complete' : 'Rest Time'}</span>
            <button type="button" onClick={onToggleTimer} aria-label={timerRunning ? 'Pause timer' : 'Start timer'}>
              {timerRunning ? <FaPause aria-hidden="true" /> : <FaPlay aria-hidden="true" />}
            </button>
          </div>
        </div>

        <div className="instruction-block">
          <h3>How to perform</h3>
          <ul>
            {exercise.instructions.map(instruction => (
              <li key={instruction}>
                <FaCheck aria-hidden="true" />
                {instruction}
              </li>
            ))}
          </ul>
        </div>

        <button type="button" className="primary-action" onClick={onCompleteSet}>
          <FaCheck aria-hidden="true" />
          Complete Set
        </button>
        <button type="button" className="outline-action" onClick={onNextExercise}>
          {exerciseIndex + 1 === day.exercises.length ? 'Finish Workout' : 'Next Exercise'}
          <FaArrowRight aria-hidden="true" />
        </button>
      </article>
    </section>
  );
}

function ProgressView({
  progress,
  completionPercent,
  totalExerciseCount,
  completedExerciseCount,
  onReset,
}: {
  progress: DemoProgress;
  completionPercent: number;
  totalExerciseCount: number;
  completedExerciseCount: number;
  onReset: () => void;
}): React.JSX.Element {
  const weeklyBars = [60, 80, 70, 90, Math.max(35, completionPercent), 60, 85];

  return (
    <section className="screen-section progress-screen">
      <article className="challenge-card">
        <div className="large-ring" style={{ '--ring-value': `${completionPercent * 3.6}deg` } as React.CSSProperties}>
          <span>{completionPercent}%</span>
        </div>
        <div>
          <h2>Challenge Progress</h2>
          <p>You&apos;re building the habit.</p>
        </div>
      </article>

      <div className="metric-grid">
        <div>
          <FaFire aria-hidden="true" />
          <strong>{Math.max(1, progress.completedDayIds.length)}</strong>
          <span>Day Streak</span>
        </div>
        <div>
          <FaCalendarAlt aria-hidden="true" />
          <strong>{progress.completedDayIds.length}</strong>
          <span>Workouts Completed</span>
        </div>
        <div>
          <FaStar aria-hidden="true" />
          <strong>{completedExerciseCount * 25}</strong>
          <span>Total Points</span>
        </div>
      </div>

      <article className="stats-card">
        <h3>Your Stats</h3>
        <div className="stats-grid">
          <StatBar label="Strength" value={Math.min(99, 62 + completedExerciseCount * 2)} />
          <StatBar label="Endurance" value={Math.min(99, 58 + progress.completedDayIds.length * 4)} />
          <StatBar label="Stability" value={Math.min(99, 64 + completedExerciseCount)} />
          <StatBar label="Mobility" value={Math.min(99, 55 + completedExerciseCount * 2)} />
        </div>
      </article>

      <article className="weekly-card">
        <h3>Weekly Progress</h3>
        <div className="bar-chart" aria-label={`${completedExerciseCount} of ${totalExerciseCount} exercises complete`}>
          {weeklyBars.map((value, index) => (
            <span key={index}>
              <strong>{value}%</strong>
              <i style={{ height: `${value}%` }} />
              <small>{['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index]}</small>
            </span>
          ))}
        </div>
        <button type="button" className="primary-action" onClick={onReset}>
          Reset Demo
          <FaArrowRight aria-hidden="true" />
        </button>
      </article>
    </section>
  );
}

function CoachView({
  whatsappUrl,
  installPromptAvailable,
  onInstall,
}: {
  whatsappUrl: string;
  installPromptAvailable: boolean;
  onInstall: () => void;
}): React.JSX.Element {
  return (
    <section className="screen-section coach-screen">
      <article className="profile-card">
        <img src={coachConfig.logoPath} alt={`${coachConfig.brandName} logo`} />
        <div>
          <h2>{coachConfig.trainerName}</h2>
          <p>{coachConfig.headline}</p>
        </div>
      </article>

      <article className="contact-card">
        <h3>Need help?</h3>
        <p>Send your trainer a quick message about form, soreness, or the next session.</p>
        <a href={whatsappUrl} target="_blank" rel="noreferrer" className="primary-action link-action">
          <FaWhatsapp aria-hidden="true" />
          Message on WhatsApp
        </a>
      </article>

      <article className="install-card">
        <h3>Install on phone</h3>
        {installPromptAvailable ? (
          <>
            <p>Tap install to add this demo to the home screen.</p>
            <button type="button" className="primary-action" onClick={onInstall}>
              Install App
            </button>
          </>
        ) : (
          <ol>
            <li>Open this demo in Chrome or Safari on your phone.</li>
            <li>Tap Share or the browser menu.</li>
            <li>Choose Add to Home Screen.</li>
          </ol>
        )}
      </article>
    </section>
  );
}

function BottomNav({ activeView, onChange }: { activeView: View; onChange: (view: View) => void }): React.JSX.Element {
  return (
    <nav className="bottom-nav" aria-label="Main demo navigation">
      <button type="button" className={activeView === 'today' ? 'active' : ''} onClick={() => onChange('today')}>
        <FaHome aria-hidden="true" />
        Today
      </button>
      <button type="button" className={activeView === 'workout' ? 'active' : ''} onClick={() => onChange('workout')}>
        <FaDumbbell aria-hidden="true" />
        Workout
      </button>
      <button type="button" className={activeView === 'progress' ? 'active' : ''} onClick={() => onChange('progress')}>
        <FaChartBar aria-hidden="true" />
        Progress
      </button>
      <button type="button" className={activeView === 'coach' ? 'active' : ''} onClick={() => onChange('coach')}>
        <FaUser aria-hidden="true" />
        Profile
      </button>
    </nav>
  );
}

function StatBar({ label, value }: { label: string; value: number }): React.JSX.Element {
  return (
    <div className="stat-bar">
      <div>
        <strong>{label}</strong>
        <span>{value}</span>
      </div>
      <small>{value >= 72 ? 'Strong' : 'Good'}</small>
      <i>
        <b style={{ width: `${value}%` }} />
      </i>
    </div>
  );
}

function getExerciseGlyph(name: string): React.JSX.Element {
  const lowerName = name.toLowerCase();

  if (lowerName.includes('walk') || lowerName.includes('march') || lowerName.includes('flow')) {
    return <FaFire aria-hidden="true" />;
  }

  if (lowerName.includes('plank') || lowerName.includes('bug') || lowerName.includes('hold')) {
    return <FaStar aria-hidden="true" />;
  }

  return <FaDumbbell aria-hidden="true" />;
}

function getSetCount(target: string): string {
  const match = target.match(/(\d+)\s*sets?/i);
  return match?.[1] ?? '3';
}

function getRepTarget(target: string): string {
  const match = target.match(/x\s*([^,]+)/i);
  return match?.[1]?.trim() ?? target;
}

function formatSeconds(seconds: number): string {
  const minutes = Math.floor(seconds / 60);
  const remaining = seconds % 60;
  return `${minutes}:${String(remaining).padStart(2, '0')}`;
}

function loadProgress(): DemoProgress {
  try {
    const raw = localStorage.getItem(storageKey);
    if (!raw) {
      return defaultProgress;
    }
    const parsed = JSON.parse(raw) as DemoProgress;
    return {
      completedExerciseIds: parsed.completedExerciseIds || [],
      completedDayIds: parsed.completedDayIds || [],
      programmeStartedAt: parsed.programmeStartedAt || new Date().toISOString(),
    };
  } catch {
    return defaultProgress;
  }
}
