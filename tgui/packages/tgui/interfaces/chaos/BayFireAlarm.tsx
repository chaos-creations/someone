import type { BooleanLike } from 'common/react';
import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section } from 'tgui/components';
import { Window } from 'tgui/layouts';

type Data = {
  fire: BooleanLike;
  alert_level: string;
  timing: BooleanLike;
  time: number;
};

/** The fire alarms of Baystation 12, as their window in the source shows them */
export const BayFireAlarm = (props) => {
  const { act, data } = useBackend<Data>();
  const seconds = data.time % 60;
  const minutes = (data.time - seconds) / 60;
  const adjust = (change: number) => act('time_adjust', { change });
  return (
    <Window width={360} height={220}>
      <Window.Content>
        <Section>
          {data.fire ? (
            <Button icon="bell-slash" onClick={() => act('reset')}>
              Reset - Lockdown
            </Button>
          ) : (
            <Button icon="bell" color="bad" onClick={() => act('alarm')}>
              Alarm - Lockdown
            </Button>
          )}
        </Section>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Alert level">
              <Box bold>{data.alert_level}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Timer System">
              <Button
                onClick={() => act('time_lock', { on: data.timing ? 0 : 1 })}
              >
                {data.timing ? 'Stop Time Lock' : 'Initiate Time Lock'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Time Left">
              <Button onClick={() => adjust(-30)}>--</Button>
              <Button onClick={() => adjust(-1)}>-</Button>
              <Box inline mx={1}>
                {minutes ? `${minutes}:` : ''}
                {seconds}
              </Box>
              <Button onClick={() => adjust(1)}>+</Button>
              <Button onClick={() => adjust(30)}>++</Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
