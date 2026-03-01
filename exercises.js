const EXERCISES = [
  {
    id: 1,
    title: "Prosjektmøte: Endret frist",
    scenario: "Du er i et prosjektmøte. Lisbeth, prosjektlederen, oppdaterer teamet.",
    dialogue: `Hei alle sammen, takk for at dere kom. Jeg har noen viktige oppdateringer fra kunden. De har bedt om å fremskynde leveransen. Den opprinnelige fristen var femten mars, men de ønsker nå at vi leverer innen første mars. Det betyr at vi har en uke mindre enn planlagt. Jeg trenger at Thomas tar ansvar for frontend-delen og sender meg en statusoppdatering innen onsdag. Maren, kan du koordinere med designteamet og sørge for at alle skisser er godkjent innen tirsdag klokken tolv? Vi møtes igjen torsdag for å se om vi er på rett spor. Har noen spørsmål?`,
    questions: [
      {
        text: "Hva er den nye fristen for leveransen?",
        options: ["15. mars", "1. mars", "Første torsdag i mars", "Ingen endring"],
        correct: 1
      },
      {
        text: "Hvem har ansvar for frontend-delen?",
        options: ["Maren", "Lisbeth", "Thomas", "Designteamet"],
        correct: 2
      },
      {
        text: "Innen når skal Maren sørge for at skissene er godkjent?",
        options: ["Onsdag klokken 12", "Tirsdag klokken 12", "Torsdag morgen", "Fredag ettermiddag"],
        correct: 1
      },
      {
        text: "Når er neste møte?",
        options: ["Mandag", "Onsdag", "Torsdag", "Fredag"],
        correct: 2
      }
    ]
  },
  {
    id: 2,
    title: "Hurtig statusrunde",
    scenario: "Teamlederen Håkon starter morgenmøtet. Det går raskt.",
    dialogue: `Ok, la oss ta en rask runde. Vi har mye å gå gjennom. Sigrid, hva er status på rapporten? Bra, men husk at ledelsen forventer et utkast til fredag, ikke neste uke. Jonas, jeg fikk beskjed fra IT om at systemet ditt fortsatt har integrasjonsproblemer. Det blokkerer testteamet. Det må fikses i dag, ellers forskyver vi hele tidslinjen. Priya, du skal presentere for kunden klokken to i ettermiddag, ikke klokken tre som vi trodde. Vær klar i møterom B. Og til alle: det er obligatorisk personalmøte neste tirsdag klokken ni. Ikke glem å bekrefte deltakelse i systemet innen fredag. Det er alt fra meg. Spørsmål?`,
    questions: [
      {
        text: "Når forventer ledelsen et utkast til rapporten?",
        options: ["Torsdag", "Fredag", "Neste uke", "Mandag"],
        correct: 1
      },
      {
        text: "Hva er problemet med Jonas sitt system?",
        options: ["Det er utdatert", "Det har integrasjonsproblemer", "Det mangler lisens", "Det er for tregt"],
        correct: 1
      },
      {
        text: "Når skal Priya presentere for kunden?",
        options: ["Klokken 13", "Klokken 14", "Klokken 15", "Klokken 16"],
        correct: 1
      },
      {
        text: "Hva er fristen for å bekrefte deltakelse på personalmøtet?",
        options: ["Mandag", "Onsdag", "Torsdag", "Fredag"],
        correct: 3
      }
    ]
  },
  {
    id: 3,
    title: "Budsjettdiskusjon",
    scenario: "Økonomisjef Astrid gjennomgår kvartalets tall.",
    dialogue: `Jeg vil gå rett på sak. Vi er over budsjett med omtrent syv prosent dette kvartalet, noe som tilsvarer rundt to hundre tusen kroner. Hoveddelen av overskridelsen skyldes reiseutgifter og ekstern konsulentbruk. Fra nå av kreves det godkjenning fra avdelingsleder for alle reiser som koster mer enn fem tusen kroner. For konsulenter gjelder det samme for kontrakter over ti tusen kroner. Unntak kan søkes om, men da trenger dere en skriftlig begrunnelse og min godkjenning minst tre virkedager i forveien. Dere vil motta en oppdatert utgiftspolicy på epost i løpet av denne uken. Les den nøye. Eventuelle spørsmål kan sendes til økonomiavdelingen. Vi forventer at alle avdelinger holder seg innenfor rammene neste kvartal.`,
    questions: [
      {
        text: "Hvor mye er teamet over budsjett?",
        options: ["5%", "7%", "10%", "15%"],
        correct: 1
      },
      {
        text: "Hva er grensen for reiser som krever godkjenning?",
        options: ["2 000 kr", "5 000 kr", "10 000 kr", "15 000 kr"],
        correct: 1
      },
      {
        text: "Hva må man gjøre for å få unntak fra reglene?",
        options: [
          "Sende en epost til teamlederen",
          "Spørre i møtet",
          "Sende skriftlig begrunnelse og få godkjenning minst 3 virkedager i forveien",
          "Fylle ut et skjema etter reisen"
        ],
        correct: 2
      },
      {
        text: "Hva vil ansatte motta i løpet av uken?",
        options: ["En ny budsjettrapport", "En oppdatert utgiftspolicy", "En invitasjon til møte", "Et spørreskjema"],
        correct: 1
      }
    ]
  },
  {
    id: 4,
    title: "Teamets forventninger",
    scenario: "Ny leder Karianne snakker om forventninger til teamet.",
    dialogue: `Jeg vil være tydelig på hva jeg forventer av dere fremover. For det første: kommunikasjon. Jeg forventer at alle svarer på eposter og meldinger innen en arbeidsdag. Hvis du ikke kan svare ordentlig, send i hvert fall en kort bekreftelse på at du har fått meldingen. For det andre: møtedeltakelse. Alle møter er obligatoriske med mindre du har en svært god grunn. Gi beskjed i god tid hvis du ikke kan komme, og les alltid referatet etterpå. For det tredje: kvalitet. Jeg forventer at dere dobbeltsjekker arbeidet deres før dere sender det videre. En rask feil fra én person kan forsinke hele teamet. Vi er et lite team, og vi er avhengige av hverandre. Det betyr at pålitelighet er viktigere enn perfeksjonisme. Lever det dere lover, til avtalt tid. Lurer dere på noe, er døren min alltid åpen.`,
    questions: [
      {
        text: "Innen når forventer Karianne svar på eposter?",
        options: ["Innen en time", "Innen en arbeidsdag", "Innen to dager", "Innen en uke"],
        correct: 1
      },
      {
        text: "Hva bør du gjøre hvis du ikke kan komme på et møte?",
        options: [
          "Ingenting, det er greit å melde avbud etterpå",
          "Sende en epost etter møtet",
          "Gi beskjed i god tid og lese referatet etterpå",
          "Spørre en kollega om å representere deg"
        ],
        correct: 2
      },
      {
        text: "Hva sier Karianne er viktigere enn perfeksjonisme?",
        options: ["Kreativitet", "Hurtighet", "Pålitelighet", "Kommunikasjon"],
        correct: 2
      },
      {
        text: "Hva skal du gjøre med arbeidet ditt før du sender det videre?",
        options: ["Sende det raskt", "Dobbeltsjekke det", "Få en kollega til å godkjenne det", "Skrive en rapport om det"],
        correct: 1
      }
    ]
  },
  {
    id: 5,
    title: "Krisemøte: Teknisk feil",
    scenario: "Det er krise. Driftsleder Vegard orienterer. Han snakker fort.",
    dialogue: `Vi har et alvorlig problem. Produksjonssystemet gikk ned klokken åtte i morges og vi vet fortsatt ikke den eksakte årsaken. Konsekvensen er at omtrent tre tusen kunder ikke får tilgang til tjenesten. Kundeservice er oversvømt med henvendelser. Øyvind, jeg trenger at du og systemteamet ditt jobber utelukkende med feilsøking til dette er løst. Ingen andre oppgaver. Vilde, kan du utarbeide en kommunikasjonsmelding til kundene innen en halvtime? Hold den kortfattet, profesjonell og unngå teknisk sjargong. Vi skal oppdatere ledelsen klokken elleve. Jeg trenger en statusrapport fra deg, Øyvind, klokken ti og et kvarter. Hvis vi ikke har en løsning innen middag, eskalerer vi til ekstern support. Alle andre: hold kanalene åpne og svar umiddelbart på alle forespørsler relatert til denne saken.`,
    questions: [
      {
        text: "Klokken hva gikk systemet ned?",
        options: ["Klokken 7", "Klokken 8", "Klokken 9", "Klokken 10"],
        correct: 1
      },
      {
        text: "Omtrent hvor mange kunder er berørt?",
        options: ["300", "1 000", "3 000", "30 000"],
        correct: 2
      },
      {
        text: "Innen når skal Vilde ha kommunikasjonsmeldingen klar?",
        options: ["Innen 15 minutter", "Innen 30 minutter", "Innen en time", "Innen klokken 11"],
        correct: 1
      },
      {
        text: "Når vil de eskalere til ekstern support?",
        options: ["Klokken 10:15", "Klokken 11", "Hvis det ikke er løst innen middag", "Neste morgen"],
        correct: 2
      }
    ]
  }
];
