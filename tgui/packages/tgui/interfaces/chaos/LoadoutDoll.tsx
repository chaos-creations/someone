// Paper doll editor of the fluff loadout, opened by /datum/loadout_doll in modular_chaos.
// The body outline is made of parts, each of them a doll slot; one slot can span several parts (both legs).
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  DmIcon,
  Modal,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

import { Loader } from '../common/Loader';

type LoadoutItem = {
  name: string;
  type: string;
  fluff_cost: number;
  icon: string;
  icon_state: string;
};

type DollSlot = {
  key: string;
  name: string;
};

type Category = {
  name: string;
  items: LoadoutItem[];
};

type Data = {
  max_points: number;
  slots: DollSlot[];
  slot_items: Record<string, LoadoutItem[]>;
  other_categories: Category[];

  equipped: Record<string, LoadoutItem>;
  other: LoadoutItem[];
  points: number;
  role_loadout: string | null;
};

/** What the picker modal is open for: a doll slot, or the items under the doll */
type Picking = { slot: DollSlot } | { other: true } | null;

/** A box of the body outline on the grid, in cells (1-based); the first part of a slot shows its item */
type BodyPart = {
  slot: string;
  x: number;
  y: number;
  w?: number;
  h?: number;
};

const CELL_SIZE = 46;
const GRID_COLUMNS = 7;
const GRID_ROWS = 9;

const BODY_PARTS: BodyPart[] = [
  { slot: 'head', x: 4, y: 1 },
  { slot: 'eyes', x: 4, y: 2 },
  { slot: 'mask', x: 4, y: 3 },
  { slot: 'accessory', x: 2, y: 4, h: 2 },
  { slot: 'suit', x: 3, y: 4, w: 3, h: 2 },
  { slot: 'accessory', x: 6, y: 4, h: 2 },
  { slot: 'gloves', x: 2, y: 6 },
  { slot: 'belt', x: 3, y: 6, w: 3 },
  { slot: 'gloves', x: 6, y: 6 },
  // Held item, beside the right hand
  { slot: 'hand', x: 7, y: 6 },
  { slot: 'uniform', x: 3, y: 7, h: 2 },
  { slot: 'uniform', x: 5, y: 7, h: 2 },
  { slot: 'shoes', x: 3, y: 9 },
  { slot: 'shoes', x: 5, y: 9 },
];

const COLOR_PART = '#4b9be0';
const COLOR_EQUIPPED = '#ffd23f';

export const LoadoutDoll = () => {
  const { act, data } = useBackend<Data>();
  const { max_points, other, points, role_loadout } = data;

  const [picking, setPicking] = useState<Picking>(null);

  return (
    <Window width={680} height={540} theme="crtblue">
      {picking && (
        <Modal width="560px">
          {'slot' in picking ? (
            <SlotPicker slot={picking.slot} close={() => setPicking(null)} />
          ) : (
            <OtherPicker close={() => setPicking(null)} />
          )}
        </Modal>
      )}
      <Window.Content>
        <Section
          fill
          title={`Points: ${points} / ${max_points}`}
          buttons={
            !!role_loadout && (
              <Button icon="toolbox" onClick={() => act('role_loadout')}>
                {`${role_loadout} loadout`}
              </Button>
            )
          }
        >
          <Stack fill>
            <Stack.Item>
              <Doll setPicking={setPicking} />
            </Stack.Item>
            <Stack.Item grow>
              <Stack vertical fill>
                <Stack.Item>
                  <SlotList setPicking={setPicking} />
                </Stack.Item>
                <Stack.Item grow>
                  <Section
                    fill
                    scrollable
                    title="Other items"
                    buttons={
                      <Button
                        icon="plus"
                        onClick={() => setPicking({ other: true })}
                      >
                        Add
                      </Button>
                    }
                  >
                    {other.length === 0 && <Box color="label">None</Box>}
                    {other.map((item) => (
                      <Button
                        key={item.type}
                        icon="xmark"
                        tooltip={`Remove (${item.fluff_cost} points)`}
                        onClick={() => act('remove', { type: item.type })}
                      >
                        {item.name}
                      </Button>
                    ))}
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const Doll = (props: { readonly setPicking: (picking: Picking) => void }) => {
  const { data } = useBackend<Data>();
  const { slots, equipped, slot_items } = data;
  const { setPicking } = props;

  // All parts of the hovered slot light up together
  const [hovered, setHovered] = useState<string | null>(null);

  const shownItems = new Set<string>();

  return (
    <Box
      style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${GRID_COLUMNS}, ${CELL_SIZE}px)`,
        gridTemplateRows: `repeat(${GRID_ROWS}, ${CELL_SIZE}px)`,
        gap: '3px',
      }}
    >
      {BODY_PARTS.map((part, index) => {
        const slot = slots.find((dollSlot) => dollSlot.key === part.slot);
        if (!slot) {
          return null;
        }
        const item = equipped[slot.key];
        const available = !!slot_items[slot.key]?.length || !!item;
        // Only the first part of a slot shows the item
        const showItem = !!item && !shownItems.has(slot.key);
        shownItems.add(slot.key);
        const width = part.w || 1;
        const height = part.h || 1;
        const iconSize = Math.min(width, height, 1.5) * CELL_SIZE - 6;
        const color = item ? COLOR_EQUIPPED : COLOR_PART;

        return (
          <Tooltip
            key={index}
            content={
              available
                ? `${slot.name}: ${item ? item.name : 'empty'}`
                : `${slot.name}: no items for this slot`
            }
          >
            <div
              style={{
                gridColumn: `${part.x} / span ${width}`,
                gridRow: `${part.y} / span ${height}`,
                border: `2px dashed ${color}`,
                backgroundColor:
                  hovered === slot.key && available
                    ? 'rgba(75, 155, 224, 0.35)'
                    : 'rgba(75, 155, 224, 0.08)',
                opacity: available ? 1 : 0.35,
                cursor: available ? 'pointer' : 'default',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
              onMouseEnter={() => setHovered(slot.key)}
              onMouseLeave={() => setHovered(null)}
              onClick={() => available && setPicking({ slot })}
            >
              {showItem && (
                <DmIcon
                  icon={item.icon}
                  icon_state={item.icon_state}
                  height={`${iconSize}px`}
                  width={`${iconSize}px`}
                  fallback={<Loader />}
                />
              )}
            </div>
          </Tooltip>
        );
      })}
    </Box>
  );
};

const SlotList = (props: {
  readonly setPicking: (picking: Picking) => void;
}) => {
  const { data } = useBackend<Data>();
  const { slots, equipped, slot_items } = data;
  const { setPicking } = props;

  return (
    <Stack vertical>
      {slots.map((slot) => {
        const item = equipped[slot.key];
        const available = !!slot_items[slot.key]?.length || !!item;
        return (
          <Stack.Item key={slot.key}>
            <Button
              fluid
              color="transparent"
              opacity={available ? 1 : 0.4}
              tooltip={available ? undefined : 'No items for this slot'}
              onClick={() => available && setPicking({ slot })}
            >
              <Box inline bold width="80px">
                {slot.name}
              </Box>
              <Box inline color={item ? 'yellow' : 'label'}>
                {item ? item.name : available ? 'empty' : '—'}
              </Box>
            </Button>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

const PickerItem = (props: {
  readonly item: LoadoutItem;
  readonly selected: boolean;
  readonly affordable: boolean;
  readonly onClick: () => void;
}) => {
  const { item, selected, affordable, onClick } = props;

  return (
    <Button
      fluid
      selected={selected}
      disabled={!selected && !affordable}
      tooltip={!selected && !affordable ? 'Not enough points' : undefined}
      onClick={onClick}
    >
      <Stack align="center">
        <Stack.Item>
          <DmIcon
            icon={item.icon}
            icon_state={item.icon_state}
            height="32px"
            width="32px"
            fallback={<Loader />}
          />
        </Stack.Item>
        <Stack.Item grow>{item.name}</Stack.Item>
        <Stack.Item>{`${item.fluff_cost} pt`}</Stack.Item>
      </Stack>
    </Button>
  );
};

const SlotPicker = (props: {
  readonly slot: DollSlot;
  readonly close: () => void;
}) => {
  const { act, data } = useBackend<Data>();
  const { slot_items, equipped, points, max_points } = data;
  const { slot, close } = props;

  const current = equipped[slot.key];
  const freePoints = max_points - points + (current?.fluff_cost || 0);

  return (
    <Section
      title={slot.name}
      buttons={<Button icon="xmark" onClick={close} />}
      maxHeight="500px"
      scrollable
    >
      <Button
        fluid
        icon="ban"
        selected={!current}
        onClick={() => {
          act('unequip', { slot: slot.key });
          close();
        }}
      >
        Nothing
      </Button>
      {(slot_items[slot.key] || []).map((item) => (
        <PickerItem
          key={item.type}
          item={item}
          selected={current?.type === item.type}
          affordable={item.fluff_cost <= freePoints}
          onClick={() => {
            act('equip', { type: item.type });
            close();
          }}
        />
      ))}
    </Section>
  );
};

const OtherPicker = (props: { readonly close: () => void }) => {
  const { act, data } = useBackend<Data>();
  const { other_categories, other, points, max_points } = data;
  const { close } = props;

  const [category, setCategory] = useState(0);
  const items = other_categories[category]?.items || [];

  return (
    <Section title="Add item" buttons={<Button icon="xmark" onClick={close} />}>
      <Stack>
        <Stack.Item width="40%">
          <Tabs vertical>
            {other_categories.map((otherCategory, index) => (
              <Tabs.Tab
                key={otherCategory.name}
                selected={index === category}
                onClick={() => setCategory(index)}
              >
                {otherCategory.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Item grow>
          <Box maxHeight="460px" overflowY="auto">
            {items.map((item) => {
              const selected = other.some(
                (picked) => picked.type === item.type,
              );
              return (
                <PickerItem
                  key={item.type}
                  item={item}
                  selected={selected}
                  affordable={points + item.fluff_cost <= max_points}
                  onClick={() =>
                    act(selected ? 'remove' : 'equip', { type: item.type })
                  }
                />
              );
            })}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
