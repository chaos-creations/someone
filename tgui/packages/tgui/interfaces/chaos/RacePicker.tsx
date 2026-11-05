// Race picker of the character setup, opened by /datum/race_picker in modular_chaos.
// The races are listed on the left; the character preview in the middle shows the character as the picked race, and
// the race's description, strengths, weaknesses and options are on the right. The options are drawn from their kind
// (RACE_OPTION_* in modular_chaos/code/__DEFINES/races.dm), so a new option of a race needs nothing here.
import { type BooleanLike } from 'common/react';
import { type ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  ColorBox,
  Icon,
  Image,
  Section,
  Stack,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

type OptionChoice = {
  value: string;
  name: string;
  desc: string | null;
};

type RaceOption = {
  key: string;
  name: string;
  desc: string | null;
  kind: 'choice' | 'toggle' | 'color' | 'text';
  /** Only for the choice kind, in the order of the buttons */
  choices?: OptionChoice[];
};

type Race = {
  id: string;
  name: string;
  tagline: string | null;
  desc: string | null;
  /** Font Awesome icon */
  icon: string;
  /** "#rrggbb" */
  color: string;
  pros: string[];
  cons: string[];
  options: RaceOption[];
};

type OptionValue = string | number | BooleanLike;

type Data = {
  races: Race[];

  /** Id of the character's race */
  race: string;
  /** Option values of the character's race by key */
  values: Record<string, OptionValue>;
  /** Name of the species the character spawns as */
  species: string;
  origin: string;
  character_name: string;
  /** Base64 PNG of the character facing south, or null before the setup window made the preview */
  preview: string | null;
};

/** Scale of the 32px preview, a whole number to keep the pixels even */
const PREVIEW_SCALE = 6;
const PREVIEW_SIZE = 32 * PREVIEW_SCALE;

const COLOR_PRO = '#7ddf8a';
const COLOR_CON = '#ff7b7b';

const ANIMATIONS = `
@keyframes race-fade-in {
  from { opacity: 0; transform: translateY(6px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes race-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-4px); }
}`;

/** The color with an alpha from 0 to 255, for "#rrggbb" colors */
const withAlpha = (color: string, alpha: number) =>
  `${color}${Math.round(alpha).toString(16).padStart(2, '0')}`;

export const RacePicker = () => {
  const { data } = useBackend<Data>();
  const { races, race } = data;

  const currentRace = races.find((entry) => entry.id === race) ?? races[0];

  return (
    <Window width={940} height={600} theme="crtblue">
      <style>{ANIMATIONS}</style>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="230px">
            <RaceList races={races} current={currentRace?.id} />
          </Stack.Item>
          <Stack.Item width="280px">
            {currentRace && <PreviewStage race={currentRace} />}
          </Stack.Item>
          <Stack.Item grow basis={0}>
            {currentRace && (
              // A new card for another race replays the fade-in
              <RaceDetails key={currentRace.id} race={currentRace} />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RaceList = (props: {
  readonly races: Race[];
  /** Id of the character's race */
  readonly current: string | undefined;
}) => {
  const { act } = useBackend<Data>();
  const { races, current } = props;

  return (
    <Section fill scrollable title="Races">
      <Stack vertical>
        {races.map((entry) => (
          <Stack.Item key={entry.id}>
            <RaceCard
              race={entry}
              selected={entry.id === current}
              onClick={() => act('race', { id: entry.id })}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const RaceCard = (props: {
  readonly race: Race;
  readonly selected: boolean;
  readonly onClick: () => void;
}) => {
  const { race, selected, onClick } = props;

  return (
    <div
      onClick={selected ? undefined : onClick}
      style={{
        display: 'flex',
        alignItems: 'center',
        padding: '6px',
        cursor: selected ? 'default' : 'pointer',
        borderLeft: `3px solid ${selected ? race.color : 'transparent'}`,
        borderRadius: '2px',
        background: selected
          ? `linear-gradient(90deg, ${withAlpha(race.color, 64)}, transparent)`
          : 'rgba(255, 255, 255, 0.04)',
        boxShadow: selected ? `0 0 10px ${withAlpha(race.color, 48)}` : 'none',
        transition: 'background 0.2s, box-shadow 0.2s',
      }}
    >
      <Box
        width="42px"
        height="42px"
        mr={1}
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: '0',
          borderRadius: '50%',
          border: `1px solid ${withAlpha(race.color, 128)}`,
          backgroundColor: withAlpha(race.color, 32),
        }}
      >
        <Icon name={race.icon} size={1.6} color={race.color} />
      </Box>
      <Box style={{ minWidth: '0' }}>
        <Box bold color={selected ? race.color : 'white'}>
          {race.name}
        </Box>
        {!!race.tagline && (
          <Box color="label" fontSize="0.9em">
            {race.tagline}
          </Box>
        )}
      </Box>
    </div>
  );
};

/** The character as the picked race, on a glow of the race's color */
const PreviewStage = (props: { readonly race: Race }) => {
  const { act, data } = useBackend<Data>();
  const { preview, character_name, species, origin } = data;
  const { race } = props;

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item grow>
          <div
            style={{
              position: 'relative',
              height: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              borderRadius: '4px',
              background: `radial-gradient(ellipse at 50% 60%, ${withAlpha(race.color, 72)} 0%, ${withAlpha(race.color, 16)} 45%, transparent 75%)`,
              transition: 'background 0.4s',
            }}
          >
            {/* The floor the character stands on */}
            <div
              style={{
                position: 'absolute',
                left: '50%',
                top: `calc(50% + ${PREVIEW_SIZE * 0.42}px)`,
                width: `${PREVIEW_SIZE * 0.6}px`,
                height: '18px',
                transform: 'translateX(-50%)',
                borderRadius: '50%',
                background: `radial-gradient(ellipse, ${withAlpha(race.color, 96)}, transparent 70%)`,
              }}
            />
            {preview ? (
              <Image
                src={`data:image/png;base64,${preview}`}
                width={`${PREVIEW_SIZE}px`}
                height={`${PREVIEW_SIZE}px`}
                style={{
                  position: 'relative',
                  animation: 'race-float 4s ease-in-out infinite',
                  filter: `drop-shadow(0 0 6px ${withAlpha(race.color, 80)})`,
                }}
              />
            ) : (
              <Box color="label" italic>
                Open the character setup to see the preview.
              </Box>
            )}
          </div>
        </Stack.Item>
        <Stack.Item textAlign="center">
          <Box bold fontSize="1.3em">
            {character_name}
          </Box>
          <Box bold color={race.color}>
            {race.name}
          </Box>
          {species !== race.name && (
            <Box color="label" fontSize="0.9em">
              {species}
            </Box>
          )}
        </Stack.Item>
        <Stack.Item textAlign="center">
          <Button
            icon="earth-americas"
            tooltip="Open the origin picker"
            onClick={() => act('origin_picker')}
          >
            Origin: {origin}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RaceDetails = (props: { readonly race: Race }) => {
  const { race } = props;
  const hasTraits = race.pros.length > 0 || race.cons.length > 0;

  return (
    <Section
      fill
      scrollable
      title={
        <Box as="span" color={race.color}>
          <Icon name={race.icon} mr={1} />
          {race.name}
        </Box>
      }
    >
      <Box style={{ animation: 'race-fade-in 0.35s ease-out both' }}>
        {!!race.desc && (
          <Box italic mb={2} style={{ lineHeight: '1.4' }}>
            {race.desc}
          </Box>
        )}
        {hasTraits && (
          <Box mb={2}>
            {race.pros.map((text) => (
              <TraitLine key={text} text={text} good />
            ))}
            {race.cons.map((text) => (
              <TraitLine key={text} text={text} good={false} />
            ))}
          </Box>
        )}
        {race.options.length > 0 && (
          <>
            <SectionHeader color={race.color}>Settings</SectionHeader>
            {race.options.map((option) => (
              <OptionField key={option.key} option={option} race={race} />
            ))}
          </>
        )}
      </Box>
    </Section>
  );
};

const TraitLine = (props: {
  readonly text: string;
  readonly good: boolean;
}) => {
  const { text, good } = props;

  return (
    <Box style={{ display: 'flex' }} mb={0.5}>
      <Box width="1.4em" style={{ flexShrink: '0' }}>
        <Icon
          name={good ? 'circle-plus' : 'circle-minus'}
          color={good ? COLOR_PRO : COLOR_CON}
        />
      </Box>
      <Box>{text}</Box>
    </Box>
  );
};

const SectionHeader = (props: {
  readonly color: string;
  readonly children: string;
}) => {
  const { color, children } = props;

  return (
    <Box
      bold
      mb={1}
      pb={0.5}
      color={color}
      style={{ borderBottom: `1px solid ${withAlpha(color, 96)}` }}
    >
      {children}
    </Box>
  );
};

/** An option of the race, drawn by its kind */
const OptionField = (props: {
  readonly option: RaceOption;
  readonly race: Race;
}) => {
  const { act, data } = useBackend<Data>();
  const { values } = data;
  const { option, race } = props;
  const value = values[option.key];

  let control: ReactNode = null;
  let valueDesc: string | null = null;
  switch (option.kind) {
    case 'choice': {
      const choices = option.choices ?? [];
      control = choices.map((choice) => (
        <Button
          key={choice.value}
          selected={choice.value === value}
          onClick={() =>
            act('option', { key: option.key, value: choice.value })
          }
        >
          {choice.name}
        </Button>
      ));
      valueDesc =
        choices.find((choice) => choice.value === value)?.desc ?? null;
      break;
    }
    case 'toggle':
      control = (
        <Button.Checkbox
          checked={!!value}
          onClick={() => act('option', { key: option.key, value: !value })}
        >
          {value ? 'On' : 'Off'}
        </Button.Checkbox>
      );
      break;
    case 'color':
      control = (
        <Button onClick={() => act('ask_option', { key: option.key })}>
          <ColorBox color={String(value)} mr={1} />
          {String(value)}
        </Button>
      );
      break;
    case 'text':
      control = (
        <Button
          icon="pen"
          onClick={() => act('ask_option', { key: option.key })}
        >
          {value ? String(value) : '—'}
        </Button>
      );
      break;
  }

  return (
    <Box
      mb={1.5}
      pl={1}
      style={{ borderLeft: `2px solid ${withAlpha(race.color, 64)}` }}
    >
      <Box bold>{option.name}</Box>
      {!!option.desc && (
        <Box color="label" mb={0.5}>
          {option.desc}
        </Box>
      )}
      <Box>{control}</Box>
      {!!valueDesc && (
        <Box mt={0.5} color="label" italic>
          {valueDesc}
        </Box>
      )}
    </Box>
  );
};
