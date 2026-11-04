// Origin picker of the character setup, opened by /datum/origin_picker in modular_chaos.
// The origins are planets orbiting the stars of their star systems, in the order of the origin list (the first one
// closest), and moons orbit their planets; the buttons on top switch between the systems. Hovering a planet stops the
// orbits, clicking it zooms in and shows the origin. Accent, glyph and religion are in a separate panel.
// The planets, the stars and the backgrounds are generated from the parameters of /datum/origin and /datum/star_system.
import { type BooleanLike } from 'common/react';
import { useEffect, useRef, useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  ColorBox,
  LabeledList,
  Modal,
  Section,
  Stack,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

import {
  getBodies,
  getBodyLayers,
  getBodyPositions,
  getOrbitPeriod,
  getOrbitRadii,
  getStarLight,
  getStartAngles,
  ORBIT_TILT,
  type Size,
  Z_STAR,
} from './space/orbits';
import { PixelPlanet } from './space/PixelPlanet';
import { SpaceBackground } from './space/SpaceBackground';

type Origin = {
  name: string;
  desc: string;
  /** Key of PLANET_TYPES */
  planet_type: string;
  planet_seed: number;
  /** Diameter of the planet in px */
  planet_size: number;
  planet_colors: string[] | null;
  planet_random_colors: BooleanLike;
  planet_spin: number;
  /** In degrees */
  planet_tilt: number;
  /** Name of the origin whose planet this one orbits as a moon, or null for a planet of the star */
  moon_of: string | null;
  /** Names of the accents a character of this origin can pick */
  accents: string[];
};

type Accent = {
  name: string;
  desc: string;
  color: string;
};

type StarSystem = {
  name: string;
  /** Names of the origins on its orbits, the closest first */
  origins: string[];
  star_seed: number;
  /** Diameter of the star in px, without its flares, which reach out to twice that */
  star_size: number;
  star_colors: string[] | null;
  star_spin: number;
  background_seed: number;
  /** Name of a PixelSpace colorscheme, or 9 colors */
  background_colorscheme: string | string[];
  background_darken: BooleanLike;
  background_planets: BooleanLike;
};

type Data = {
  origins: Origin[];
  systems: StarSystem[];
  accents: Accent[];
  glyphs: string[];

  origin: string;
  accent: string;
  /** Empty for a random glyph each round */
  glyph: string;
  religion: string;
  character_name: string;
};

/** Size of the background to the view, so the background zoom doesn't show its edges */
const BACKGROUND_OVERSCAN = 1.2;

/** About the size of a clicked planet after the zoom, in px; the zoom is rounded to a whole number to keep the pixels even */
const ZOOMED_PLANET_SIZE = 300;
/** Where the zoomed planet stands, as a part of the view width */
const ZOOM_X = 0.28;
const ZOOM_SECONDS = 0.9;
/** Zoom of the background when a planet is zoomed in, which is less than the planets' for depth */
const BACKGROUND_ZOOM = 1.15;

const COLOR_ORBIT = 'rgba(255, 255, 255, 0.12)';
const COLOR_CURRENT = '#ffd23f';

const CARD_ANIMATION = `
@keyframes origin-card-in {
  from { opacity: 0; transform: translate(20px, -50%); }
  to { opacity: 1; transform: translate(0, -50%); }
}`;

export const OriginPicker = () => {
  const { act, data } = useBackend<Data>();
  const { origins, systems, origin } = data;

  const [settingsOpen, setSettingsOpen] = useState(false);
  // Opens on the system of the character's origin
  const [systemName, setSystemName] = useState(
    () =>
      (systems.find((system) => system.origins.includes(origin)) ?? systems[0])
        ?.name,
  );
  const system =
    systems.find((entry) => entry.name === systemName) ?? systems[0];

  return (
    <Window width={960} height={720} theme="crtblue">
      <style>{CARD_ANIMATION}</style>
      {settingsOpen && (
        <Modal width="600px">
          <SettingsPanel close={() => setSettingsOpen(false)} />
        </Modal>
      )}
      <Window.Content fitted>
        {system && (
          <SystemView
            // A new view for another system: its orbits, zoom and hover start over
            key={system.name}
            system={system}
            origins={system.origins
              .map((name) => origins.find((entry) => entry.name === name))
              .filter((entry): entry is Origin => !!entry)}
            current={origin}
            choose={(name) => act('origin', { name })}
          />
        )}
        <TopBar
          systems={systems}
          system={system?.name}
          selectSystem={setSystemName}
          openSettings={() => setSettingsOpen(true)}
        />
      </Window.Content>
    </Window>
  );
};

type SystemViewProps = {
  readonly system: StarSystem;
  /** Origins of the system: planets the closest first, and moons */
  readonly origins: Origin[];
  /** Name of the character's origin */
  readonly current: string;
  readonly choose: (name: string) => void;
};

/** A star system: its background, star, and origin planets and moons on their orbits */
const SystemView = (props: SystemViewProps) => {
  const { system, origins, current, choose } = props;

  const [hovered, setHovered] = useState<string | null>(null);
  const [focused, setFocused] = useState<string | null>(null);
  const [size, setSize] = useState<Size>({ width: 0, height: 0 });

  const bodies = getBodies(origins);
  const planetCount = bodies.filter((body) => body.parent === null).length;
  const radii = getOrbitRadii(bodies, system.star_size, size);

  const viewRef = useRef<HTMLDivElement>(null);
  const bodyRefs = useRef<(HTMLDivElement | null)[]>([]);
  // The orbit loop moves the bodies without rendering, so it reads the state through refs
  const anglesRef = useRef(getStartAngles(bodies));
  const bodiesRef = useRef(bodies);
  bodiesRef.current = bodies;
  const radiiRef = useRef(radii);
  radiiRef.current = radii;
  const sizeRef = useRef(size);
  sizeRef.current = size;
  const pausedRef = useRef(false);
  pausedRef.current = hovered !== null || focused !== null;

  /** Where the bodies are now */
  const getPositions = () =>
    getBodyPositions(
      bodiesRef.current,
      radiiRef.current,
      sizeRef.current,
      anglesRef.current,
    );

  useEffect(() => {
    const view = viewRef.current;
    if (!view) {
      return;
    }
    const measure = () =>
      setSize({ width: view.clientWidth, height: view.clientHeight });
    measure();
    const observer = new ResizeObserver(measure);
    observer.observe(view);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    let frame = 0;
    let lastTime = performance.now();
    const tick = (time: number) => {
      const seconds = (time - lastTime) / 1000;
      lastTime = time;
      const angles = anglesRef.current;
      const currentBodies = bodiesRef.current;
      if (!pausedRef.current) {
        currentBodies.forEach((body, index) => {
          const turn = (seconds * 2 * Math.PI) / getOrbitPeriod(body);
          // A broken step would leave the body at NaN for good
          if (Number.isFinite(turn)) {
            angles[index] += turn;
          }
        });
      }
      const positions = getPositions();
      const layers = getBodyLayers(currentBodies, positions, sizeRef.current);
      currentBodies.forEach((body, index) => {
        const element = bodyRefs.current[index];
        if (!element) {
          return;
        }
        const position = positions[index];
        const radius = body.origin.planet_size / 2;
        element.style.transform = `translate(${position.x - radius}px, ${position.y - radius}px)`;
        element.style.zIndex = `${layers[index]}`;
      });
      frame = requestAnimationFrame(tick);
    };
    frame = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frame);
  }, []);

  /** Light of the body from the star */
  const getLight = (index: number) =>
    getStarLight(getPositions()[index], sizeRef.current);

  const focusedIndex = bodies.findIndex((body) => body.origin.name === focused);
  const focusedOrigin = focusedIndex >= 0 ? bodies[focusedIndex].origin : null;

  // Moves the clicked body (stopped since the hover) to its place on the left of the view
  let worldTransform = 'translate(0px, 0px) scale(1)';
  if (focusedOrigin) {
    const position = getBodyPositions(bodies, radii, size, anglesRef.current)[
      focusedIndex
    ];
    const zoom = Math.max(
      1,
      Math.round(ZOOMED_PLANET_SIZE / focusedOrigin.planet_size),
    );
    worldTransform = `translate(${size.width * ZOOM_X - position.x * zoom}px, ${size.height / 2 - position.y * zoom}px) scale(${zoom})`;
  }

  return (
    <div
      ref={viewRef}
      style={{
        position: 'absolute',
        inset: 0,
        overflow: 'hidden',
        backgroundColor: '#05080f',
        cursor: focusedOrigin ? 'zoom-out' : 'default',
      }}
      onClick={() => setFocused(null)}
    >
      <div
        style={{
          position: 'absolute',
          left: `${(size.width * (1 - BACKGROUND_OVERSCAN)) / 2}px`,
          top: `${(size.height * (1 - BACKGROUND_OVERSCAN)) / 2}px`,
          transform: `scale(${focusedOrigin ? BACKGROUND_ZOOM : 1})`,
          transition: `transform ${ZOOM_SECONDS}s ease-in-out`,
        }}
      >
        <SpaceBackground
          seed={system.background_seed}
          colorscheme={system.background_colorscheme}
          darken={!!system.background_darken}
          planets={!!system.background_planets}
          width={Math.round(size.width * BACKGROUND_OVERSCAN)}
          height={Math.round(size.height * BACKGROUND_OVERSCAN)}
          style={{ display: 'block' }}
        />
      </div>
      <div
        style={{
          position: 'absolute',
          inset: 0,
          transformOrigin: '0 0',
          transform: worldTransform,
          transition: `transform ${ZOOM_SECONDS}s ease-in-out`,
        }}
      >
        {bodies.slice(0, planetCount).map((body, index) => (
          <Orbit
            key={body.origin.name}
            radius={radii[index] ?? 0}
            size={size}
            current={
              body.origin.name === current ||
              bodies.some(
                (moon) => moon.parent === index && moon.origin.name === current,
              )
            }
            hidden={!!focusedOrigin}
          />
        ))}
        <div
          style={{
            position: 'absolute',
            left: `${Math.round(size.width / 2 - system.star_size / 2)}px`,
            top: `${Math.round(size.height / 2 - system.star_size / 2)}px`,
            width: `${system.star_size}px`,
            height: `${system.star_size}px`,
            zIndex: Z_STAR,
          }}
        >
          <PixelPlanet
            type="star"
            seed={system.star_seed}
            pixels={system.star_size}
            colors={system.star_colors}
            speed={system.star_spin}
          />
        </div>
        {bodies.map((body, index) => (
          <Planet
            key={body.origin.name}
            planetRef={(element) => {
              bodyRefs.current[index] = element;
            }}
            origin={body.origin}
            current={body.origin.name === current}
            hovered={body.origin.name === hovered}
            showLabel={!focusedOrigin}
            getLight={() => getLight(index)}
            onHover={(isHovered) =>
              setHovered(isHovered ? body.origin.name : null)
            }
            onClick={() => setFocused(body.origin.name)}
          />
        ))}
      </div>
      {!focusedOrigin && (
        <Box
          position="absolute"
          bottom="10px"
          left={0}
          right={0}
          textAlign="center"
          color="label"
          style={{ zIndex: '40', pointerEvents: 'none' }}
        >
          Click a planet to look at it closer
        </Box>
      )}
      {focusedOrigin && (
        <OriginCard
          key={focusedOrigin.name}
          origin={focusedOrigin}
          current={focusedOrigin.name === current}
          choose={() => choose(focusedOrigin.name)}
          back={() => setFocused(null)}
        />
      )}
    </div>
  );
};

const Orbit = (props: {
  readonly radius: number;
  readonly size: Size;
  readonly current: boolean;
  readonly hidden: boolean;
}) => {
  const { radius, size, current, hidden } = props;

  return (
    <div
      style={{
        position: 'absolute',
        left: `${size.width / 2 - radius}px`,
        top: `${size.height / 2 - radius * ORBIT_TILT}px`,
        width: `${radius * 2}px`,
        height: `${radius * 2 * ORBIT_TILT}px`,
        border: `1px solid ${current ? COLOR_CURRENT : COLOR_ORBIT}`,
        borderRadius: '50%',
        opacity: hidden ? 0 : current ? 0.5 : 1,
        transition: `opacity ${ZOOM_SECONDS * 0.5}s`,
        pointerEvents: 'none',
      }}
    />
  );
};

type PlanetProps = {
  readonly planetRef: (element: HTMLDivElement | null) => void;
  readonly origin: Origin;
  readonly current: boolean;
  readonly hovered: boolean;
  readonly showLabel: boolean;
  /** Light from the star for the planet's frame, see PixelPlanet */
  readonly getLight: () => number[];
  readonly onHover: (hovered: boolean) => void;
  readonly onClick: () => void;
};

/** A planet, moved along its orbit by the orbit loop of SystemView through the ref */
const Planet = (props: PlanetProps) => {
  const {
    planetRef,
    origin,
    current,
    hovered,
    showLabel,
    getLight,
    onHover,
    onClick,
  } = props;
  const planetSize = `${origin.planet_size}px`;
  // Without WebGL2 the planet is a plain disk
  const [drawingFailed, setDrawingFailed] = useState(false);

  let glow = 'none';
  if (hovered) {
    glow = 'drop-shadow(0 0 8px rgba(255, 255, 255, 0.7))';
  } else if (current) {
    glow = 'drop-shadow(0 0 6px rgba(255, 210, 63, 0.6))';
  }
  const glowStyle = { filter: glow, transition: 'filter 0.2s' };

  return (
    <div
      ref={planetRef}
      style={{
        position: 'absolute',
        left: 0,
        top: 0,
        width: planetSize,
        height: planetSize,
        cursor: 'pointer',
      }}
      onMouseEnter={() => onHover(true)}
      onMouseLeave={() => onHover(false)}
      onClick={(event) => {
        event.stopPropagation();
        onClick();
      }}
    >
      {drawingFailed ? (
        <div
          style={{
            ...glowStyle,
            width: planetSize,
            height: planetSize,
            borderRadius: '50%',
            backgroundColor: '#555',
          }}
        />
      ) : (
        <PixelPlanet
          type={origin.planet_type}
          seed={origin.planet_seed}
          pixels={origin.planet_size}
          colors={origin.planet_colors}
          randomColors={!!origin.planet_random_colors}
          tilt={(origin.planet_tilt * Math.PI) / 180}
          speed={origin.planet_spin}
          getLight={getLight}
          onUnsupported={() => setDrawingFailed(true)}
          style={glowStyle}
        />
      )}
      {showLabel && (hovered || current) && (
        <Box
          position="absolute"
          top={planetSize}
          left="50%"
          bold
          color={current ? COLOR_CURRENT : 'white'}
          style={{
            transform: 'translateX(-50%)',
            whiteSpace: 'nowrap',
            textShadow: '0 0 3px black',
            pointerEvents: 'none',
            zIndex: '1',
          }}
        >
          {origin.name}
        </Box>
      )}
    </div>
  );
};

const TopBar = (props: {
  readonly systems: StarSystem[];
  /** Name of the shown system */
  readonly system: string | undefined;
  readonly selectSystem: (name: string) => void;
  readonly openSettings: () => void;
}) => {
  const { data } = useBackend<Data>();
  const { origin } = data;
  const { systems, system, selectSystem, openSettings } = props;

  return (
    <>
      <Box
        position="absolute"
        top="8px"
        left="12px"
        style={{ zIndex: '10', textShadow: '0 0 3px black' }}
      >
        <Box bold>
          Origin:{' '}
          <Box as="span" color={COLOR_CURRENT}>
            {origin}
          </Box>
        </Box>
        <ChatPreview />
      </Box>
      {systems.length > 1 && (
        <Box
          position="absolute"
          top="8px"
          left="50%"
          style={{ zIndex: '10', transform: 'translateX(-50%)' }}
        >
          {systems.map((entry) => (
            <Button
              key={entry.name}
              icon="sun"
              selected={entry.name === system}
              onClick={() => selectSystem(entry.name)}
            >
              {entry.name}
            </Button>
          ))}
        </Box>
      )}
      <Box position="absolute" top="8px" right="12px" style={{ zIndex: '10' }}>
        <Button icon="sliders" onClick={openSettings}>
          Accent, glyph and religion
        </Button>
      </Box>
    </>
  );
};

const OriginCard = (props: {
  readonly origin: Origin;
  readonly current: boolean;
  readonly choose: () => void;
  readonly back: () => void;
}) => {
  const { origin, current, choose, back } = props;

  return (
    <div
      style={{
        position: 'absolute',
        top: '50%',
        right: '4%',
        width: '40%',
        zIndex: 10,
        cursor: 'default',
        animation: `origin-card-in 0.4s ease-out ${ZOOM_SECONDS * 0.6}s both`,
      }}
      onClick={(event) => event.stopPropagation()}
    >
      <Section
        title={origin.name}
        buttons={
          <Button icon="arrow-left" onClick={back}>
            Back
          </Button>
        }
      >
        <Box italic mb={2}>
          {origin.desc}
        </Box>
        {current ? (
          <Box bold color={COLOR_CURRENT}>
            This is your origin.
          </Box>
        ) : (
          <Button icon="check" onClick={choose}>
            Choose this origin
          </Button>
        )}
      </Section>
    </div>
  );
};

/** How the character's name looks in chat, with the glyph in the accent color */
const ChatPreview = () => {
  const { data } = useBackend<Data>();
  const { accents, accent, glyph, character_name } = data;

  const color = accents.find((entry) => entry.name === accent)?.color;

  return (
    <Box>
      <Box as="span" bold color={color}>
        {glyph || '?'}
      </Box>{' '}
      {character_name} says, &quot;Hello.&quot;
    </Box>
  );
};

const SettingsPanel = (props: { readonly close: () => void }) => {
  const { act, data } = useBackend<Data>();
  const { origins, origin, religion } = data;
  const { close } = props;

  const currentOrigin = origins.find((entry) => entry.name === origin);

  return (
    <Stack vertical>
      <Stack.Item>
        <AccentSection origin={currentOrigin} />
      </Stack.Item>
      <Stack.Item>
        <GlyphSection />
      </Stack.Item>
      <Stack.Item>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Religion">
              <Button onClick={() => act('religion')}>{religion}</Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item textAlign="right">
        <Button icon="xmark" onClick={close}>
          Close
        </Button>
      </Stack.Item>
    </Stack>
  );
};

const AccentSection = (props: { readonly origin: Origin | undefined }) => {
  const { act, data } = useBackend<Data>();
  const { accents, accent } = data;
  const { origin } = props;

  const allowedAccents = accents.filter((entry) =>
    origin?.accents.includes(entry.name),
  );
  const currentAccent = accents.find((entry) => entry.name === accent);

  return (
    <Section title="Accent">
      {allowedAccents.map((entry) => (
        <Button
          key={entry.name}
          selected={entry.name === accent}
          onClick={() => act('accent', { name: entry.name })}
        >
          <ColorBox color={entry.color} mr={1} />
          {entry.name}
        </Button>
      ))}
      {!!currentAccent?.desc && (
        <Box mt={1} color="label">
          {currentAccent.desc}
        </Box>
      )}
    </Section>
  );
};

const GlyphSection = () => {
  const { act, data } = useBackend<Data>();
  const { glyph, glyphs } = data;

  return (
    <Section
      title="Glyph"
      buttons={
        <Button
          icon="dice"
          selected={!glyph}
          tooltip="A new glyph every round"
          onClick={() => act('glyph', { glyph: '' })}
        >
          Random
        </Button>
      }
    >
      <Box mb={1}>
        {glyphs.map((entry) => (
          <Button
            key={entry}
            width="2.2em"
            textAlign="center"
            selected={entry === glyph}
            onClick={() => act('glyph', { glyph: entry })}
          >
            {entry}
          </Button>
        ))}
      </Box>
      <Box color="label">In chat:</Box>
      <ChatPreview />
    </Section>
  );
};
