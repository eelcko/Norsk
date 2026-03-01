const SPEEDS = {
  slow:   { rate: 0.75, label: "Langsom",    description: "God tid til å prosessere" },
  normal: { rate: 1.0,  label: "Normal",     description: "Som en rolig kollega" },
  fast:   { rate: 1.3,  label: "Rask",       description: "Som et normalt møte" },
  expert: { rate: 1.55, label: "Ekspert",    description: "Som når alle snakker fort" }
};

const state = {
  currentExercise: null,
  currentSpeed: "normal",
  score: { correct: 0, total: 0 },
  utterance: null,
  speaking: false,
  phase: "select" // select | listening | questions | result
};

function $(id) { return document.getElementById(id); }

function render() {
  $("select-screen").classList.toggle("hidden", state.phase !== "select");
  $("listening-screen").classList.toggle("hidden", state.phase !== "listening");
  $("questions-screen").classList.toggle("hidden", state.phase !== "questions");
  $("result-screen").classList.toggle("hidden", state.phase !== "result");
}

function buildExerciseList() {
  const list = $("exercise-list");
  list.innerHTML = "";
  EXERCISES.forEach(ex => {
    const card = document.createElement("div");
    card.className = "exercise-card";
    card.innerHTML = `<div class="ex-title">${ex.title}</div><div class="ex-scenario">${ex.scenario}</div>`;
    card.addEventListener("click", () => startExercise(ex));
    list.appendChild(card);
  });
}

function buildSpeedSelector() {
  const container = $("speed-selector");
  container.innerHTML = "";
  Object.entries(SPEEDS).forEach(([key, val]) => {
    const btn = document.createElement("button");
    btn.className = "speed-btn" + (key === state.currentSpeed ? " active" : "");
    btn.innerHTML = `<span class="speed-name">${val.label}</span><span class="speed-desc">${val.description}</span>`;
    btn.addEventListener("click", () => {
      state.currentSpeed = key;
      buildSpeedSelector();
    });
    container.appendChild(btn);
  });
}

function startExercise(ex) {
  state.currentExercise = ex;
  state.phase = "listening";
  render();

  $("listening-title").textContent = ex.title;
  $("listening-scenario").textContent = ex.scenario;
  $("play-btn").disabled = false;
  $("play-btn").textContent = "▶ Spill av";
  $("no-replay-warning").classList.add("hidden");
  $("proceed-btn").classList.add("hidden");
}

function speak() {
  if (state.speaking) return;

  const ex = state.currentExercise;
  const speed = SPEEDS[state.currentSpeed];

  $("play-btn").disabled = true;
  $("play-btn").textContent = "Lytter...";
  $("no-replay-warning").classList.remove("hidden");
  state.speaking = true;

  const utterance = new SpeechSynthesisUtterance(ex.dialogue);
  utterance.lang = "nb-NO";
  utterance.rate = speed.rate;
  utterance.pitch = 1.0;

  // Try to find a Norwegian voice
  const voices = speechSynthesis.getVoices();
  const norwegianVoice = voices.find(v => v.lang.startsWith("nb") || v.lang.startsWith("no"));
  if (norwegianVoice) utterance.voice = norwegianVoice;

  utterance.onend = () => {
    state.speaking = false;
    $("play-btn").textContent = "Ferdig";
    $("proceed-btn").classList.remove("hidden");
  };

  utterance.onerror = () => {
    state.speaking = false;
    $("play-btn").disabled = false;
    $("play-btn").textContent = "▶ Prøv igjen";
    showTTSFallback();
  };

  state.utterance = utterance;
  speechSynthesis.speak(utterance);
}

function showTTSFallback() {
  const el = $("tts-fallback");
  if (el) {
    el.classList.remove("hidden");
  }
}

function showQuestions() {
  state.phase = "questions";
  render();

  const ex = state.currentExercise;
  $("q-title").textContent = ex.title;
  const container = $("questions-container");
  container.innerHTML = "";

  ex.questions.forEach((q, qi) => {
    const block = document.createElement("div");
    block.className = "question-block";
    block.innerHTML = `<div class="question-text">${qi + 1}. ${q.text}</div>`;

    const opts = document.createElement("div");
    opts.className = "options";
    q.options.forEach((opt, oi) => {
      const btn = document.createElement("button");
      btn.className = "option-btn";
      btn.textContent = opt;
      btn.dataset.qi = qi;
      btn.dataset.oi = oi;
      btn.addEventListener("click", () => selectOption(qi, oi, q.correct, btn, opts));
      opts.appendChild(btn);
    });

    block.appendChild(opts);
    container.appendChild(block);
  });

  $("submit-answers-btn").classList.remove("hidden");
  $("submit-answers-btn").disabled = true;
}

let answers = {};

function selectOption(qi, oi, correct, btn, opts) {
  // Only allow one answer per question
  if (opts.querySelector(".selected")) return;

  btn.classList.add("selected");
  answers[qi] = oi;

  // Enable submit if all questions answered
  const ex = state.currentExercise;
  if (Object.keys(answers).length === ex.questions.length) {
    $("submit-answers-btn").disabled = false;
  }
}

function submitAnswers() {
  const ex = state.currentExercise;
  let correct = 0;

  ex.questions.forEach((q, qi) => {
    const selected = answers[qi];
    const allBtns = document.querySelectorAll(`.option-btn[data-qi="${qi}"]`);
    allBtns.forEach(b => {
      const oi = parseInt(b.dataset.oi);
      if (oi === q.correct) b.classList.add("correct");
      else if (oi === selected && selected !== q.correct) b.classList.add("wrong");
    });
    if (selected === q.correct) correct++;
  });

  state.score.correct += correct;
  state.score.total += ex.questions.length;

  $("submit-answers-btn").classList.add("hidden");
  $("view-result-btn").classList.remove("hidden");

  // Store result for display
  state.lastResult = { correct, total: ex.questions.length };
}

function showResult() {
  state.phase = "result";
  render();

  const { correct, total } = state.lastResult;
  const pct = Math.round((correct / total) * 100);

  $("result-score").textContent = `${correct} / ${total}`;
  $("result-pct").textContent = `${pct}%`;

  const feedback = $("result-feedback");
  if (pct === 100) {
    feedback.textContent = "Perfekt! Du fanget opp alt — ingen detaljer gikk tapt.";
    feedback.className = "feedback excellent";
  } else if (pct >= 75) {
    feedback.textContent = "Veldig bra! Du fikk med deg det viktigste. Øv mer for å fange opp alle detaljer.";
    feedback.className = "feedback good";
  } else if (pct >= 50) {
    feedback.textContent = "Greit! Du forstod deler av det. Prøv samme øvelse i lavere hastighet, og jobb deg opp.";
    feedback.className = "feedback ok";
  } else {
    feedback.textContent = "Dette var krevende! Start med 'Langsom' hastighet og bygg opp gradvis.";
    feedback.className = "feedback hard";
  }

  $("session-score").textContent = `Total sesjon: ${state.score.correct} / ${state.score.total} riktige`;

  const speedNow = SPEEDS[state.currentSpeed];
  const nextSpeed = getNextSpeed();
  const tip = $("next-tip");
  if (pct === 100 && nextSpeed) {
    tip.textContent = `Du mestret ${speedNow.label}! Prøv neste nivå: ${SPEEDS[nextSpeed].label}.`;
    tip.classList.remove("hidden");
  } else {
    tip.classList.add("hidden");
  }
}

function getNextSpeed() {
  const order = ["slow", "normal", "fast", "expert"];
  const idx = order.indexOf(state.currentSpeed);
  return idx < order.length - 1 ? order[idx + 1] : null;
}

function tryNextLevel() {
  const next = getNextSpeed();
  if (next) {
    state.currentSpeed = next;
    buildSpeedSelector();
  }
  backToSelect();
}

function backToSelect() {
  answers = {};
  state.lastResult = null;
  state.currentExercise = null;
  state.phase = "select";
  render();
}

// Init
document.addEventListener("DOMContentLoaded", () => {
  buildExerciseList();
  buildSpeedSelector();
  render();

  $("play-btn").addEventListener("click", speak);
  $("proceed-btn").addEventListener("click", showQuestions);
  $("submit-answers-btn").addEventListener("click", submitAnswers);
  $("view-result-btn").addEventListener("click", showResult);
  $("back-btn").addEventListener("click", backToSelect);
  $("next-level-btn").addEventListener("click", tryNextLevel);
  $("another-btn").addEventListener("click", backToSelect);

  // Voices may load async
  speechSynthesis.onvoiceschanged = () => {};
});
