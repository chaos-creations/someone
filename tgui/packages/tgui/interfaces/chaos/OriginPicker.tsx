// Origin, accent and chat glyph picker of the character setup, opened by /datum/origin_picker in modular_chaos.
import { resolveAsset } from 'tgui/assets';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  ColorBox,
  Image,
  LabeledList,
  Section,
  Stack,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

type Origin = {
  name: string;
  desc: string;
  /** Asset name of the homeworld picture */
  planet: string | null;
  /** Names of the accents a character of this origin can pick */
  accents: string[];
};

type Accent = {
  name: string;
  desc: string;
  color: string;
};

type Data = {
  origins: Origin[];
  accents: Accent[];
  glyphs: string[];

  origin: string;
  accent: string;
  /** Empty for a random glyph each round */
  glyph: string;
  religion: string;
  character_name: string;
};

const PLANET_SIZE = 200;
const GLYPH_BUTTON_WIDTH = '2.2em';

export const OriginPicker = () => {
  const { data } = useBackend<Data>();
  const { origins, origin } = data;

  const currentOrigin = origins.find((entry) => entry.name === origin);

  return (
    <Window width={760} height={600} theme="crtblue">
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="210px">
            <OriginList />
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item>
                <OriginCard origin={currentOrigin} />
              </Stack.Item>
              <Stack.Item>
                <AccentSection origin={currentOrigin} />
              </Stack.Item>
              <Stack.Item grow>
                <GlyphSection />
              </Stack.Item>
              <Stack.Item>
                <ReligionSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const OriginList = () => {
  const { act, data } = useBackend<Data>();
  const { origins, origin } = data;

  return (
    <Section fill scrollable title="Origins">
      {origins.map((entry) => (
        <Button
          key={entry.name}
          fluid
          selected={entry.name === origin}
          onClick={() => act('origin', { name: entry.name })}
        >
          {entry.name}
        </Button>
      ))}
    </Section>
  );
};

const OriginCard = (props: { readonly origin: Origin | undefined }) => {
  const { origin } = props;

  if (!origin) {
    return (
      <Section title="Origin">
        <Box color="label">Pick an origin from the list.</Box>
      </Section>
    );
  }

  return (
    <Section title={origin.name}>
      <Stack>
        <Stack.Item>
          {origin.planet ? (
            <Image
              src={resolveAsset(origin.planet)}
              width={`${PLANET_SIZE}px`}
              height={`${PLANET_SIZE}px`}
            />
          ) : (
            <Box
              width={`${PLANET_SIZE}px`}
              height={`${PLANET_SIZE}px`}
              color="label"
              textAlign="center"
              lineHeight={`${PLANET_SIZE}px`}
              backgroundColor="rgba(0, 0, 0, 0.3)"
            >
              No picture
            </Box>
          )}
        </Stack.Item>
        <Stack.Item grow>
          <Box italic>{origin.desc}</Box>
        </Stack.Item>
      </Stack>
    </Section>
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
  const { accents, accent, glyph, glyphs, character_name } = data;

  const color = accents.find((entry) => entry.name === accent)?.color;

  return (
    <Section
      fill
      scrollable
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
            width={GLYPH_BUTTON_WIDTH}
            textAlign="center"
            selected={entry === glyph}
            onClick={() => act('glyph', { glyph: entry })}
          >
            {entry}
          </Button>
        ))}
      </Box>
      <Box color="label">In chat:</Box>
      <Box>
        <Box as="span" bold color={color}>
          {glyph || '?'}
        </Box>{' '}
        {character_name} says, &quot;Hello.&quot;
      </Box>
    </Section>
  );
};

const ReligionSection = () => {
  const { act, data } = useBackend<Data>();
  const { religion } = data;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Religion">
          <Button onClick={() => act('religion')}>{religion}</Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
