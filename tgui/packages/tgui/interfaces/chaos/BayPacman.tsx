import type { BooleanLike } from 'common/react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

type Data = {
  active: BooleanLike;
  output_set: number;
  output_max: number;
  output_safe: number;
  output_watts: number;
  temperature_current: number;
  temperature_max: number;
  temperature_overheat: number;
  fuel_stored: number;
  fuel_capacity: number;
  fuel_usage: number;
  fuel_type: string;
};

/** The P.A.C.M.A.N. generators of Baystation 12, as nano/templates/pacman.tmpl of the source shows them */
export const BayPacman = (props) => {
  const { act, data } = useBackend<Data>();
  const fuelColor =
    (data.fuel_stored >= 5000 && 'good') ||
    (data.fuel_stored >= 1000 && 'average') ||
    'bad';
  const temperatureColor =
    (data.temperature_current < data.temperature_max * 0.8 && 'good') ||
    (data.temperature_current < data.temperature_max && 'average') ||
    'bad';
  const overheat = data.temperature_overheat;
  return (
    <Window width={500} height={460}>
      <Window.Content scrollable>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Generator Status">
              {data.active ? (
                <Box color="good">Online</Box>
              ) : (
                <Box color="average">Offline</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Generator Control">
              {data.active ? (
                <Button icon="power-off" onClick={() => act('disable')}>
                  STOP
                </Button>
              ) : (
                <Button icon="power-off" onClick={() => act('enable')}>
                  START
                </Button>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Fuel">
          <LabeledList>
            <LabeledList.Item label="Fuel Type">
              <Box color="good">{data.fuel_type}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Fuel Level">
              <ProgressBar
                value={data.fuel_stored}
                minValue={0}
                maxValue={data.fuel_capacity}
                color={fuelColor}
              >
                {data.fuel_stored}/{data.fuel_capacity} cm3
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Fuel Usage">
              <Box color="good">{data.fuel_usage} cm3/s</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Control">
              <Button
                icon="eject"
                disabled={data.active}
                onClick={() => act('eject_fuel')}
              >
                EJECT FUEL
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Output">
          <LabeledList>
            <LabeledList.Item label="Power setting">
              <Box color={data.output_set > data.output_safe ? 'bad' : 'good'}>
                {data.output_set} / {data.output_max} ({data.output_watts} W)
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Control">
              <Button icon="plus" onClick={() => act('output_higher')} />
              <Button icon="minus" onClick={() => act('output_lower')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Temperature">
          <LabeledList>
            <LabeledList.Item label="Temperature">
              <ProgressBar
                value={data.temperature_current}
                minValue={0}
                maxValue={data.temperature_max * 1.5}
                color={temperatureColor}
              >
                {data.temperature_current} C
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Generator Status">
              {(overheat > 90 && (
                <Box color="bad">
                  DANGER: CRITICAL OVERHEAT! Deactivate generator immediately!
                </Box>
              )) ||
                (overheat > 50 && (
                  <Box color="average">WARNING: Overheating!</Box>
                )) ||
                (overheat > 10 && (
                  <Box color="average">Temperature High</Box>
                )) || <Box color="good">Optimal</Box>}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
