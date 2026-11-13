import type { BooleanLike } from 'common/react';
import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section } from 'tgui/components';
import { Window } from 'tgui/layouts';

type Data = {
  generated: number;
  sun_angle: number;
  sun_direction: string;
  array_angle: number;
  array_direction: string;
  track: number;
  trackrate: number;
  panels: number;
  tracker: BooleanLike;
};

const TRACKING_MODES = ['Off', 'Timed', 'Auto'];

/** The solar control consoles of Baystation 12, as their window in the source shows them */
export const BaySolarControl = (props) => {
  const { act, data } = useBackend<Data>();
  const turn = (change: number) => act('turn', { change });
  const rate = (change: number) => act('rate', { change });
  return (
    <Window width={420} height={340}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Generated power">
              {data.generated} W
            </LabeledList.Item>
            <LabeledList.Item label="Star Orientation">
              {data.sun_angle}&deg; ({data.sun_direction})
            </LabeledList.Item>
            <LabeledList.Item label="Array Orientation">
              <Button onClick={() => turn(-15)}>--</Button>
              <Button onClick={() => turn(-1)}>-</Button>
              <Box inline mx={1}>
                {data.array_angle}&deg; ({data.array_direction})
              </Box>
              <Button onClick={() => turn(1)}>+</Button>
              <Button onClick={() => turn(15)}>++</Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Tracking">
          <LabeledList>
            <LabeledList.Item label="Mode">
              {TRACKING_MODES.map((mode, index) => (
                <Button
                  key={mode}
                  selected={data.track === index}
                  onClick={() => act('track', { track: index })}
                >
                  {mode}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Tracking Rate">
              <Button onClick={() => rate(-180)}>---</Button>
              <Button onClick={() => rate(-30)}>--</Button>
              <Button onClick={() => rate(-1)}>-</Button>
              <Box inline mx={1}>
                {data.trackrate} deg/h ({data.trackrate < 0 ? 'CCW' : 'CW'})
              </Box>
              <Button onClick={() => rate(1)}>+</Button>
              <Button onClick={() => rate(30)}>++</Button>
              <Button onClick={() => rate(180)}>+++</Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Connected devices"
          buttons={
            <Button icon="search" onClick={() => act('search')}>
              Search for devices
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Solar panels">
              {data.panels} connected
            </LabeledList.Item>
            <LabeledList.Item label="Solar tracker">
              {data.tracker ? (
                <Box color="good">Found</Box>
              ) : (
                <Box color="bad">Not found</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
