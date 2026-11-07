import type { BooleanLike } from 'common/react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

type Piece = {
  name: string;
  deployed: BooleanLike;
  sealed: BooleanLike;
};

type Module = {
  ref: string;
  name: string;
  desc: string;
  selectable: BooleanLike;
  selected: BooleanLike;
  active: BooleanLike;
  aiming: BooleanLike;
  use_cost: number;
  active_cost: number;
};

type Data = {
  name: string;
  worn: BooleanLike;
  sealed: BooleanLike;
  sealing: BooleanLike;
  online: BooleanLike;
  has_cell: BooleanLike;
  charge: number;
  max_charge: number;
  charging_source: string | null;
  cable_out: BooleanLike;
  pieces: Piece[];
  has_helmet: BooleanLike;
  has_tank: BooleanLike;
  tank_name: string | null;
  tank_pressure: number;
  air_open: BooleanLike;
  modules: Module[];
};

const suitStatus = (data: Data) => {
  if (data.sealing) {
    return { text: 'Adjusting seals', color: 'average' };
  }
  if (data.online) {
    return { text: 'Online', color: 'good' };
  }
  if (data.sealed) {
    return { text: 'Offline: no power', color: 'bad' };
  }
  return { text: 'Retracted', color: 'label' };
};

export const Hardsuit = (props) => {
  const { act, data } = useBackend<Data>();
  const status = suitStatus(data);
  const locked = !data.worn;

  return (
    <Window width={460} height={620}>
      <Window.Content scrollable>
        {!data.worn && (
          <NoticeBox>
            The hardsuit has to be worn on the back to be controlled.
          </NoticeBox>
        )}
        <Section
          title="Suit"
          buttons={
            <>
              <Button
                icon="user-shield"
                disabled={locked || data.sealing}
                selected={data.sealed}
                onClick={() => act('toggle_suit')}
              >
                {data.sealed ? 'Retract' : 'Deploy'}
              </Button>
              {!!data.has_helmet && (
                <Button
                  icon="helmet-safety"
                  disabled={locked || data.sealing}
                  onClick={() => act('toggle_helmet')}
                >
                  Helmet
                </Button>
              )}
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Status" color={status.color}>
              {status.text}
            </LabeledList.Item>
            <LabeledList.Item label="Cell">
              {data.has_cell ? (
                <ProgressBar
                  value={data.charge}
                  maxValue={data.max_charge}
                  ranges={{
                    good: [data.max_charge * 0.5, Infinity],
                    average: [data.max_charge * 0.2, data.max_charge * 0.5],
                    bad: [-Infinity, data.max_charge * 0.2],
                  }}
                >
                  {Math.round(data.charge)} / {data.max_charge}
                </ProgressBar>
              ) : (
                <Box color="bad">No cell installed</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item
              label="Charging cable"
              buttons={
                <Button
                  icon="plug"
                  disabled={locked}
                  selected={!!data.charging_source || data.cable_out}
                  onClick={() => act('cable')}
                >
                  {data.charging_source
                    ? 'Unplug'
                    : data.cable_out
                      ? 'Wind back'
                      : 'Pull out'}
                </Button>
              }
            >
              {data.charging_source
                ? `Plugged into ${data.charging_source}`
                : data.cable_out
                  ? 'In hand'
                  : 'Wound up'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Pieces">
          <Table>
            {data.pieces.map((piece) => (
              <Table.Row key={piece.name}>
                <Table.Cell>{piece.name}</Table.Cell>
                <Table.Cell
                  collapsing
                  color={
                    piece.sealed ? 'good' : piece.deployed ? 'average' : 'label'
                  }
                >
                  {piece.sealed
                    ? 'Sealed'
                    : piece.deployed
                      ? 'Deployed'
                      : 'Retracted'}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
        <Section
          title="Air supply"
          buttons={
            !!data.has_tank && (
              <Button
                icon="wind"
                disabled={locked}
                selected={data.air_open}
                onClick={() => act('toggle_air')}
              >
                {data.air_open ? 'Close' : 'Open'}
              </Button>
            )
          }
        >
          {data.has_tank ? (
            <LabeledList>
              <LabeledList.Item label="Tank">{data.tank_name}</LabeledList.Item>
              <LabeledList.Item label="Pressure">
                {data.tank_pressure} kPa
              </LabeledList.Item>
              <LabeledList.Item label="Valve">
                {data.air_open ? 'Feeding the helmet' : 'Closed'}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="bad">No tank installed</Box>
          )}
        </Section>
        <Section title="Modules">
          {data.modules.length === 0 && (
            <Box color="label">No modules installed.</Box>
          )}
          <Stack vertical>
            {data.modules.map((module) => (
              <Stack.Item key={module.ref}>
                <Stack align="center">
                  <Stack.Item grow>
                    <Box
                      bold={!!module.selected}
                      color={module.active ? 'good' : undefined}
                    >
                      {module.name}
                      {!!module.aiming && ' (ready)'}
                    </Box>
                    <Box color="label" fontSize="0.9em">
                      {module.desc}
                      {module.use_cost > 0 && ` Use: ${module.use_cost}.`}
                      {module.active_cost > 0 &&
                        ` On: ${module.active_cost}/s.`}
                    </Box>
                  </Stack.Item>
                  {!!module.selectable && (
                    <>
                      <Stack.Item>
                        <Button
                          icon="crosshairs"
                          disabled={locked}
                          selected={module.selected}
                          onClick={() =>
                            act('select_module', { ref: module.ref })
                          }
                        >
                          Select
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="power-off"
                          disabled={locked}
                          selected={module.active || module.aiming}
                          onClick={() => act('use_module', { ref: module.ref })}
                        >
                          Use
                        </Button>
                      </Stack.Item>
                    </>
                  )}
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
