import { type BooleanLike } from 'common/react';
import { useRef, useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  ColorBox,
  DmIcon,
  Dropdown,
  Icon,
  Image,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  TextArea,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

type CatalogEntry = {
  path: string;
  name: string;
  icon: string;
  icon_state: string;
  size: string;
  desc: string;
  /** Whether the item is of the kinds gear presets are usually made of, listed without a search */
  common: BooleanLike;
};

type AppearanceStyle = {
  name: string;
  icon: string;
  icon_state: string;
  gender: 'male' | 'female' | 'any';
};

/** What the appearance panel offers for the mannequin's species; empty when it does not change how the species looks */
type AppearanceOptions = {
  /** Skin colors, with a swatch color for the human ones */
  skin_colors: { name: string; color: string | null }[];
  body_types: string[];
  body_sizes: string[];
  /** Names of the underwear and undershirts each body can wear, null for species without underwear */
  underwear: Record<'male' | 'female', string[]> | null;
  undershirts: Record<'male' | 'female', string[]> | null;
  hair_styles: AppearanceStyle[];
  /** Whether the species' hair takes the hair color */
  hair_colored: BooleanLike;
  facial_hair_styles: AppearanceStyle[];
};

type Appearance = {
  gender: 'male' | 'female';
  skin_color: string;
  body_type: string;
  body_size: string;
  underwear: string;
  undershirt: string;
  h_style: string;
  hair_color: string;
  f_style: string;
  facial_hair_color: string;
  eye_color: string;
};

type Container = {
  ref: string;
  name: string;
  items: GearItem[];
  used: number;
  max: number;
  unit: 'slots' | 'space';
  max_size?: string;
};

type GearItem = {
  ref: string;
  name: string;
  path: string;
  icon: string;
  icon_state: string;
  size: string;
  accepts_accessories?: BooleanLike;
  accessories?: GearItem[];
  containers: Container[];
};

type Slot = {
  id: string;
  name: string;
  item: GearItem | null;
};

type Picker = {
  kind: 'slot' | 'container' | 'accessory';
  title?: string;
  container?: Container;
};

type Data = {
  /** Picture of the mannequin, as base64 PNG */
  preview: string;
  /** Size of the picture in pixels; overlays larger than a tile are centered on the mannequin */
  preview_size: [number, number];
  appearance: Appearance;
  appearance_options: AppearanceOptions;
  custom_appearance: BooleanLike;
  species: string;
  species_list: string[];
  catalog: CatalogEntry[];
  /** Indexes into catalog of the entries that fit where the picker is open */
  picker_items: number[];
  picker: Picker | null;
  slots: Slot[];
  message: string | null;
  message_is_error: BooleanLike;
  preset_name: string;
  preset_path: string;
  export_json: string | null;
  export_code: string | null;
};

const ItemIcon = (props: {
  readonly icon: string;
  readonly icon_state: string;
}) => (
  <DmIcon
    icon={props.icon}
    icon_state={props.icon_state}
    width="32px"
    height="32px"
    fallback={<Icon name="box" size={2} />}
    // Keeps wide sprites like guns from being squeezed into the square
    {...{ objectFit: 'contain' }}
    style={{ verticalAlign: 'middle' }}
  />
);

const Message = () => {
  const { data } = useBackend<Data>();
  const { message, message_is_error } = data;
  if (!message) {
    return null;
  }
  return message_is_error ? (
    <NoticeBox danger>{message}</NoticeBox>
  ) : (
    <NoticeBox info>{message}</NoticeBox>
  );
};

/** Characters of the imported JSON sent per message, well under the about 20 KB a tgui message can carry */
const IMPORT_PART_SIZE = 15000;

/** What the right side of the window shows */
type View = 'gear' | 'export' | 'import' | 'appearance';

export const GearPresetBuilder = () => {
  const { act, data } = useBackend<Data>();
  const [view, setView] = useState<View>('gear');

  const openView = (next: View) => {
    if (data.picker) {
      act('close_picker');
    }
    if (next === 'export') {
      act('export');
    } else if (data.export_json) {
      act('close_export');
    }
    setView(next);
  };

  return (
    <Window width={1100} height={800}>
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="36%">
            <LeftPanel
              onExport={() => openView('export')}
              onImport={() => openView('import')}
              onAppearance={() => openView('appearance')}
            />
          </Stack.Item>
          <Stack.Item grow>
            {view === 'export' && data.export_json ? (
              <ExportPanel onClose={() => openView('gear')} />
            ) : view === 'import' ? (
              <ImportPanel onClose={() => openView('gear')} />
            ) : view === 'appearance' ? (
              <AppearancePanel onClose={() => openView('gear')} />
            ) : data.picker ? (
              <PickerPanel picker={data.picker} />
            ) : (
              <Section fill scrollable title="Gear">
                {data.slots.map((slot) => (
                  <SlotRow key={slot.id} slot={slot} />
                ))}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const LeftPanel = (props: {
  readonly onExport: () => void;
  readonly onImport: () => void;
  readonly onAppearance: () => void;
}) => {
  const { act, data } = useBackend<Data>();

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          title="Preview"
          buttons={
            <>
              <Button
                icon="rotate-left"
                onClick={() => act('rotate', { clockwise: false })}
              />
              <Button
                icon="rotate-right"
                onClick={() => act('rotate', { clockwise: true })}
              />
            </>
          }
        >
          <Box
            height="100%"
            position="relative"
            style={{ overflow: 'hidden', containerType: 'size' }}
          >
            {/* One tile of the mannequin always fills the shorter side, so overlays sticking out of it do not shrink it */}
            <Image
              src={`data:image/png;base64,${data.preview}`}
              position="absolute"
              style={{
                left: '50%',
                top: '50%',
                transform: 'translate(-50%, -50%)',
                width: `calc(${data.preview_size[0] / TILE_SIZE} * 100cqmin)`,
                height: `calc(${data.preview_size[1] / TILE_SIZE} * 100cqmin)`,
                maxWidth: 'none',
              }}
            />
          </Box>
        </Section>
      </Stack.Item>
      {!data.picker && (
        <Stack.Item>
          <Message />
        </Stack.Item>
      )}
      <Stack.Item>
        <Section title="Preset">
          <Stack vertical>
            <Stack.Item>
              <Input
                fluid
                placeholder="Name"
                value={data.preset_name}
                onChange={(e, value) => act('set_name', { name: value })}
              />
            </Stack.Item>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item color="label">/datum/equipment_preset/</Stack.Item>
                <Stack.Item grow>
                  <Input
                    fluid
                    monospace
                    value={data.preset_path}
                    onChange={(e, value) => act('set_path', { path: value })}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Button icon="file-export" onClick={props.onExport}>
                Export
              </Button>
              <Button icon="file-import" onClick={props.onImport}>
                Import
              </Button>
              <Button icon="folder-open" onClick={() => act('load_preset')}>
                Load preset
              </Button>
              <Button icon="user-pen" onClick={props.onAppearance}>
                Appearance
              </Button>
              <Button icon="person" onClick={() => act('spawn')}>
                Spawn here
              </Button>
              <Button.Confirm
                icon="trash"
                color="bad"
                onClick={() => act('clear')}
              >
                Clear
              </Button.Confirm>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const SlotRow = (props: { readonly slot: Slot }) => {
  const { act } = useBackend<Data>();
  const { slot } = props;
  const { item } = slot;

  return (
    <Box mb={1} pb={0.5} style={{ borderBottom: '1px solid #ffffff1a' }}>
      <Stack align="center">
        <Stack.Item width="7em" color="label">
          {slot.name}
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            color="transparent"
            onClick={() =>
              act('open_picker', { kind: 'slot', target: slot.id })
            }
          >
            {item ? <ItemLabel item={item} /> : <Box color="grey">empty</Box>}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            color="bad"
            disabled={!item}
            onClick={() => act('unequip', { slot: slot.id })}
          />
        </Stack.Item>
      </Stack>
      {!!item && <ItemChildren item={item} />}
    </Box>
  );
};

const ItemLabel = (props: { readonly item: GearItem | CatalogEntry }) => {
  const { item } = props;
  return (
    <>
      <ItemIcon icon={item.icon} icon_state={item.icon_state} /> {item.name}{' '}
      <Box inline color="label" fontSize="0.85em">
        ({item.size})
      </Box>
    </>
  );
};

const ItemChildren = (props: { readonly item: GearItem }) => {
  const { act } = useBackend<Data>();
  const { item } = props;

  return (
    <Box ml={2}>
      {!!item.accepts_accessories && (
        <Box mt={0.5}>
          <Stack align="center">
            <Stack.Item grow color="label">
              Accessories
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="plus"
                onClick={() =>
                  act('open_picker', { kind: 'accessory', target: item.ref })
                }
              >
                Attach
              </Button>
            </Stack.Item>
          </Stack>
          {item.accessories?.map((accessory) => (
            <ChildRow key={accessory.ref} item={accessory} />
          ))}
        </Box>
      )}
      {item.containers.map((container) => (
        <ContainerBox key={container.ref} container={container} />
      ))}
    </Box>
  );
};

const ContainerFill = (props: { readonly container: Container }) => {
  const { container } = props;
  return (
    <ProgressBar
      value={container.used}
      maxValue={Math.max(container.max, 1)}
      color={container.used >= container.max ? 'bad' : 'good'}
    >
      {container.used} / {container.max} {container.unit}
      {container.max_size && `, up to ${container.max_size}`}
    </ProgressBar>
  );
};

const ContainerBox = (props: { readonly container: Container }) => {
  const { act } = useBackend<Data>();
  const { container } = props;

  return (
    <Box mt={0.5}>
      <Stack align="center">
        <Stack.Item color="label" width="7em">
          {container.name}
        </Stack.Item>
        <Stack.Item grow>
          <ContainerFill container={container} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="plus"
            disabled={container.used >= container.max}
            onClick={() =>
              act('open_picker', { kind: 'container', target: container.ref })
            }
          >
            Add
          </Button>
        </Stack.Item>
      </Stack>
      {container.items.map((child) => (
        <ChildRow key={child.ref} item={child} />
      ))}
    </Box>
  );
};

const ChildRow = (props: { readonly item: GearItem }) => {
  const { act } = useBackend<Data>();
  const { item } = props;

  return (
    <Box ml={1}>
      <Stack align="center">
        <Stack.Item grow>
          <ItemLabel item={item} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            color="bad"
            onClick={() => act('remove', { ref: item.ref })}
          />
        </Stack.Item>
      </Stack>
      <ItemChildren item={item} />
    </Box>
  );
};

/** Pixels in a tile, the size of the mannequin's own sprite */
const TILE_SIZE = 32;

/** Readable names of common type path segments, the rest are shown as they are */
const SEGMENT_NAMES: Record<string, string> = {
  ammo_magazine: 'Ammo',
  attachable: 'Attachments',
  clothing: 'Clothing',
  device: 'Devices',
  explosive: 'Explosives',
  reagent_container: 'Reagent containers',
  stack: 'Stacks',
  storage: 'Storage',
  tool: 'Tools',
  weapon: 'Weapons',
};

/** Group of entries whose paths are the same right after the common part */
const BASE_GROUP = '(base)';

const ALL_GROUPS = '';

const segmentName = (segment: string) =>
  segment === BASE_GROUP
    ? 'Other'
    : SEGMENT_NAMES[segment] ||
      segment.charAt(0).toUpperCase() + segment.slice(1).replace(/_/g, ' ');

/** Splits a type path into its segments: "/obj/item/foo" into ["obj", "item", "foo"] */
const pathSegments = (path: string) => path.split('/').filter(Boolean);

/** Number of leading path segments every entry shares, so groups start where the paths differ */
const commonDepth = (entries: CatalogEntry[]) => {
  if (entries.length === 0) {
    return 0;
  }
  let common = pathSegments(entries[0].path);
  for (const entry of entries) {
    const segments = pathSegments(entry.path);
    let depth = 0;
    while (
      depth < common.length &&
      depth < segments.length &&
      common[depth] === segments[depth]
    ) {
      depth++;
    }
    common = common.slice(0, depth);
  }
  // Every entry's own type is never part of the common prefix, so a lone subtype still lands in a group
  const shortest = Math.min(
    ...entries.map((entry) => pathSegments(entry.path).length),
  );
  return Math.min(common.length, shortest - 1);
};

/** Key of the group an entry falls into at a depth of its path */
const groupAt = (entry: CatalogEntry, depth: number) =>
  pathSegments(entry.path)[depth] ?? BASE_GROUP;

/** Counts entries per group key, largest groups first */
const countGroups = (entries: CatalogEntry[], depth: number) => {
  const counts: Record<string, number> = {};
  for (const entry of entries) {
    const key = groupAt(entry, depth);
    counts[key] = (counts[key] || 0) + 1;
  }
  return Object.entries(counts).sort(
    (first, second) =>
      second[1] - first[1] || first[0].localeCompare(second[0]),
  );
};

const PickerPanel = (props: { readonly picker: Picker }) => {
  const { act, data } = useBackend<Data>();
  const { picker } = props;
  const [query, setQuery] = useState('');
  const [group, setGroup] = useState(ALL_GROUPS);
  const [subgroup, setSubgroup] = useState(ALL_GROUPS);
  const [showEverything, setShowEverything] = useState(false);

  const fitting = data.picker_items.map((index) => data.catalog[index]);
  const depth = commonDepth(fitting);

  const search = query.trim().toLowerCase();
  // Without a search only the usual gear is listed, a search looks through everything that fits
  const searched = fitting.filter((entry) =>
    search
      ? entry.name.toLowerCase().includes(search) || entry.path.includes(search)
      : showEverything || entry.common,
  );
  const groups = countGroups(searched, depth);
  const inGroup = searched.filter(
    (entry) => !group || groupAt(entry, depth) === group,
  );
  const subgroups = group ? countGroups(inGroup, depth + 1) : [];
  const shown = inGroup
    .filter((entry) => !subgroup || groupAt(entry, depth + 1) === subgroup)
    .sort(
      (first, second) =>
        first.path.localeCompare(second.path) ||
        first.name.localeCompare(second.name),
    );

  return (
    <Section
      fill
      title={picker.title}
      buttons={
        <Button icon="arrow-left" onClick={() => act('close_picker')}>
          Back
        </Button>
      }
    >
      <Stack fill vertical>
        {!!picker.container && (
          <Stack.Item>
            <ContainerFill container={picker.container} />
          </Stack.Item>
        )}
        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>
              <Input
                fluid
                autoFocus
                expensive
                placeholder="Search everything that fits by name or path..."
                value={query}
                onInput={(e, value) => setQuery(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox
                checked={showEverything}
                disabled={!!search}
                tooltip="Without it, only the usual preset gear is listed: clothing, storage, weapons, ammo, tools, devices, medicine"
                onClick={() => {
                  setShowEverything(!showEverything);
                  setGroup(ALL_GROUPS);
                  setSubgroup(ALL_GROUPS);
                }}
              >
                Show everything
              </Button.Checkbox>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Message />
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill>
            <Stack.Item width="13em">
              <Section fill scrollable>
                <Tabs vertical>
                  <Tabs.Tab
                    selected={!group}
                    onClick={() => {
                      setGroup(ALL_GROUPS);
                      setSubgroup(ALL_GROUPS);
                    }}
                  >
                    All ({searched.length})
                  </Tabs.Tab>
                  {groups.map(([key, count]) => (
                    <Tabs.Tab
                      key={key}
                      selected={group === key}
                      onClick={() => {
                        setGroup(key);
                        setSubgroup(ALL_GROUPS);
                      }}
                    >
                      {segmentName(key)} ({count})
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable>
                {subgroups.length > 1 && (
                  <Box mb={1}>
                    <Button
                      selected={!subgroup}
                      onClick={() => setSubgroup(ALL_GROUPS)}
                    >
                      All ({inGroup.length})
                    </Button>
                    {subgroups.map(([key, count]) => (
                      <Button
                        key={key}
                        selected={subgroup === key}
                        onClick={() => setSubgroup(key)}
                      >
                        {segmentName(key)} ({count})
                      </Button>
                    ))}
                  </Box>
                )}
                {shown.length === 0 && (
                  <Box color="label">Nothing fits here.</Box>
                )}
                {shown.map((entry) => (
                  <Button
                    key={entry.path}
                    width="72px"
                    height="72px"
                    m="2px"
                    tooltip={
                      <Box maxWidth="320px">
                        <b>{entry.name}</b> ({entry.size})
                        <Box
                          color="label"
                          fontSize="0.85em"
                          style={{ wordBreak: 'break-all' }}
                        >
                          {entry.path}
                        </Box>
                        {!!entry.desc && <Box mt={0.5}>{entry.desc}</Box>}
                      </Box>
                    }
                    onClick={() => act('pick', { path: entry.path })}
                  >
                    <DmIcon
                      icon={entry.icon}
                      icon_state={entry.icon_state}
                      width="64px"
                      height="64px"
                      fallback={<Icon name="box" size={3} mt={2} />}
                      {...{ objectFit: 'contain' }}
                    />
                  </Button>
                ))}
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AppearancePanel = (props: { readonly onClose: () => void }) => {
  const { act, data } = useBackend<Data>();
  const { appearance, appearance_options: options } = data;
  const [hairSearch, setHairSearch] = useState('');

  const setField = (field: string, value: string) =>
    act('set_appearance', { field: field, value: value });

  const search = hairSearch.trim().toLowerCase();
  const hairStyles = options.hair_styles.filter(
    (style) => !search || style.name.toLowerCase().includes(search),
  );
  const facialHairStyles = options.facial_hair_styles.filter(
    (style) => style.gender === 'any' || style.gender === appearance.gender,
  );

  return (
    <Section
      fill
      scrollable
      title="Appearance"
      buttons={
        <>
          <Button.Checkbox
            checked={!!data.custom_appearance}
            tooltip="Export the appearance with the preset; without it, mobs of the preset look random"
            onClick={() => act('toggle_custom_appearance')}
          >
            Use in export
          </Button.Checkbox>
          <Button icon="dice" onClick={() => act('randomize_appearance')}>
            Randomize
          </Button>
          <Button icon="arrow-left" onClick={props.onClose}>
            Back
          </Button>
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item
          label="Species"
          tooltip="Exported with the preset whatever the checkbox, as its load_race(). The options below are the ones this species has"
        >
          <Dropdown
            width="100%"
            options={data.species_list}
            selected={data.species}
            onSelected={(value) => act('set_species', { species: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Body">
          <Button
            icon="mars"
            selected={appearance.gender === 'male'}
            onClick={() => setField('gender', 'male')}
          >
            Male
          </Button>
          <Button
            icon="venus"
            selected={appearance.gender === 'female'}
            onClick={() => setField('gender', 'female')}
          >
            Female
          </Button>
        </LabeledList.Item>
        {options.skin_colors.length > 0 && (
          <LabeledList.Item label="Skin">
            {options.skin_colors.map((skin) => (
              <Button
                key={skin.name}
                tooltip={skin.name}
                selected={appearance.skin_color === skin.name}
                onClick={() => setField('skin_color', skin.name)}
              >
                {skin.color ? <ColorBox color={skin.color} /> : skin.name}
              </Button>
            ))}
          </LabeledList.Item>
        )}
        {options.body_types.length > 0 && (
          <LabeledList.Item label="Build">
            {options.body_types.map((bodyType) => (
              <Button
                key={bodyType}
                selected={appearance.body_type === bodyType}
                onClick={() => setField('body_type', bodyType)}
              >
                {bodyType}
              </Button>
            ))}
          </LabeledList.Item>
        )}
        {options.body_sizes.length > 0 && (
          <LabeledList.Item label="Size">
            {options.body_sizes.map((bodySize) => (
              <Button
                key={bodySize}
                selected={appearance.body_size === bodySize}
                onClick={() => setField('body_size', bodySize)}
              >
                {bodySize}
              </Button>
            ))}
          </LabeledList.Item>
        )}
        {!!options.underwear && (
          <LabeledList.Item label="Underwear">
            <Dropdown
              width="100%"
              options={options.underwear[appearance.gender]}
              selected={appearance.underwear}
              onSelected={(value) => setField('underwear', value)}
            />
          </LabeledList.Item>
        )}
        {!!options.undershirts && (
          <LabeledList.Item label="Undershirt">
            <Dropdown
              width="100%"
              options={options.undershirts[appearance.gender]}
              selected={appearance.undershirt}
              onSelected={(value) => setField('undershirt', value)}
            />
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Colors">
          {!!options.hair_colored && (
            <Button onClick={() => act('pick_color', { field: 'hair_color' })}>
              <ColorBox color={appearance.hair_color} mr={1} />
              Hair
            </Button>
          )}
          {options.facial_hair_styles.length > 0 && (
            <Button
              onClick={() => act('pick_color', { field: 'facial_hair_color' })}
            >
              <ColorBox color={appearance.facial_hair_color} mr={1} />
              Facial hair
            </Button>
          )}
          <Button onClick={() => act('pick_color', { field: 'eye_color' })}>
            <ColorBox color={appearance.eye_color} mr={1} />
            Eyes
          </Button>
        </LabeledList.Item>
      </LabeledList>
      {options.hair_styles.length > 0 && (
        <Section title={`Hair: ${appearance.h_style}`} mt={1}>
          <Input
            fluid
            expensive
            placeholder="Search hair styles..."
            value={hairSearch}
            onInput={(e, value) => setHairSearch(value)}
            mb={1}
          />
          {hairStyles.map((style) => (
            <StyleButton
              key={style.name}
              style={style}
              selected={appearance.h_style === style.name}
              onClick={() => setField('h_style', style.name)}
            />
          ))}
        </Section>
      )}
      {facialHairStyles.length > 0 && (
        <Section title={`Facial hair: ${appearance.f_style}`}>
          {facialHairStyles.map((style) => (
            <StyleButton
              key={style.name}
              style={style}
              selected={appearance.f_style === style.name}
              onClick={() => setField('f_style', style.name)}
            />
          ))}
        </Section>
      )}
    </Section>
  );
};

const StyleButton = (props: {
  readonly style: AppearanceStyle;
  readonly selected: boolean;
  readonly onClick: () => void;
}) => (
  <Button
    width="72px"
    height="72px"
    m="2px"
    tooltip={props.style.name}
    selected={props.selected}
    onClick={props.onClick}
  >
    <DmIcon
      icon={props.style.icon}
      icon_state={`${props.style.icon_state}_s`}
      width="64px"
      height="64px"
      fallback={<Icon name="user" size={3} mt={2} />}
    />
  </Button>
);

const ExportPanel = (props: { readonly onClose: () => void }) => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useState<'code' | 'json'>('code');
  const text = (tab === 'code' ? data.export_code : data.export_json) || '';

  return (
    <Section
      fill
      title="Export"
      buttons={
        <>
          <Button icon="download" onClick={() => act('download')}>
            Download JSON
          </Button>
          <Button icon="arrow-left" onClick={props.onClose}>
            Back
          </Button>
        </>
      }
    >
      <Stack fill vertical>
        <Stack.Item>
          <Tabs>
            <Tabs.Tab selected={tab === 'code'} onClick={() => setTab('code')}>
              DM code
            </Tabs.Tab>
            <Tabs.Tab selected={tab === 'json'} onClick={() => setTab('json')}>
              JSON
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Item color="label">
          Select the text and copy it with Ctrl+C. The JSON can be imported back
          into the builder.
        </Stack.Item>
        <Stack.Item grow>
          <TextArea key={tab} fluid height="100%" value={text} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/**
 * Sends a pasted export to the server: only its name, path and slots, compact, split into parts small enough
 * for tgui messages, so the export's code and formatting do not push it over the message size limit
 *
 * Returns an error to show, or null once it is sent
 */
const sendImport = (
  act: (action: string, payload?: object) => void,
  text: string,
): string | null => {
  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch {
    return 'That is not valid JSON. Paste the JSON tab of an export, not the DM code.';
  }
  if (!parsed || typeof parsed !== 'object' || !parsed.slots) {
    return 'The JSON has no "slots". Paste the JSON tab of an export.';
  }
  const compact = JSON.stringify({
    name: parsed.name,
    path: parsed.path,
    slots: parsed.slots,
  });
  const parts = Math.ceil(compact.length / IMPORT_PART_SIZE);
  for (let part = 0; part < parts; part++) {
    act('import', {
      json: compact.slice(
        part * IMPORT_PART_SIZE,
        (part + 1) * IMPORT_PART_SIZE,
      ),
      part: part + 1,
      parts: parts,
    });
  }
  return null;
};

const ImportPanel = (props: { readonly onClose: () => void }) => {
  const { act } = useBackend<Data>();
  // The text area reports its value on blur, which comes right before the button click, so it is kept in a ref
  const text = useRef('');
  const [error, setError] = useState<string | null>(null);

  return (
    <Section
      fill
      title="Import"
      buttons={
        <>
          <Button
            icon="file-import"
            onClick={() => {
              const result = sendImport(act, text.current);
              setError(result);
              if (!result) {
                props.onClose();
              }
            }}
          >
            Import
          </Button>
          <Button icon="arrow-left" onClick={props.onClose}>
            Back
          </Button>
        </>
      }
    >
      <Stack fill vertical>
        <Stack.Item color="label">
          Paste the JSON tab of an export. It replaces the current gear.
        </Stack.Item>
        {!!error && (
          <Stack.Item>
            <NoticeBox danger>{error}</NoticeBox>
          </Stack.Item>
        )}
        <Stack.Item grow>
          <TextArea
            autoFocus
            fluid
            height="100%"
            onChange={(e, value) => {
              text.current = value;
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
