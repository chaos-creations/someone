// Trimmed copy of interfaces/LobbyMenu.tsx: only the character name, Setup Character, Observe and Ready / Join.
// Opened by /mob/new_player/tgui_interact() in modular_chaos; styles come from upstream's LobbyMenu.scss.
import type { BooleanLike } from 'common/react';
import { classes } from 'common/react';
import { storage } from 'common/storage';
import {
  type ComponentProps,
  createContext,
  type PropsWithChildren,
  type ReactNode,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react';
import { resolveAsset } from 'tgui/assets';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button as NativeButton,
  Modal,
  Section,
  Stack,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

import { LoadingScreen } from '../common/LoadingToolbox';

type LobbyData = {
  lobby_author: string;

  character_name: string;

  round_start: BooleanLike;
  round_starting: BooleanLike;
  readied: BooleanLike;

  confirmation_message?: string | string[];

  upp_enabled: BooleanLike;
  upp_join_enabled: BooleanLike;

  preference_issues: string[];
};

type LobbyContextType = {
  animationsDisable: boolean;
  themeDisable: boolean;
  setModal?: (_: ReactNode | false) => void;
};

const LobbyContext = createContext<LobbyContextType>({
  animationsDisable: false,
  themeDisable: false,
});

export const LobbyMenu = () => {
  const { act, data } = useBackend<LobbyData>();

  const { lobby_author, upp_enabled, confirmation_message, preference_issues } =
    data;

  const onLoadPlayer = useRef<HTMLAudioElement>(null);

  const [modal, setModal] = useState<ReactNode | false>(false);

  const [disableAnimations, setDisableAnimations] = useState(false);
  const [filterDisabled, setFilterDisabled] = useState(false);
  const [themeDisabled, setThemeDisabled] = useState<boolean | undefined>();

  useEffect(() => {
    storage
      .get('lobby-filter-disabled')
      .then((val) => setFilterDisabled(!!val));

    storage.get('lobby-theme-disabled').then((val) => setThemeDisabled(!!val));

    setTimeout(() => {
      onLoadPlayer.current!.play();
    }, 250);

    setTimeout(() => {
      setDisableAnimations(true);
    }, 10000);
  }, []);

  useEffect(() => {
    if (!confirmation_message) return;

    setModal(
      <Section
        buttons={
          <Button
            mb={5}
            onClick={() => {
              setModal!(false);
              act('unconfirm');
            }}
            icon={'x'}
          />
        }
        p={3}
        title={'Confirm'}
      >
        <Box>
          <Stack vertical>
            {Array.isArray(confirmation_message) ? (
              confirmation_message.map((element, index) => (
                <Stack.Item key={index}>{element}</Stack.Item>
              ))
            ) : (
              <Stack.Item>{confirmation_message}</Stack.Item>
            )}
          </Stack>
          <Stack justify="center">
            <Stack.Item>
              <Button onClick={() => act('confirm')}>Confirm</Button>
            </Stack.Item>
          </Stack>
        </Box>
      </Section>,
    );
  }, [confirmation_message]);

  if (themeDisabled === undefined) {
    return (
      <Window fitted scrollbars={false}>
        <Window.Content>
          <LoadingScreen />
        </Window.Content>
      </Window>
    );
  }

  const themeToUse = themeDisabled
    ? 'weyland_yutani'
    : upp_enabled
      ? 'crtlobbyred'
      : 'crtlobby';

  return (
    <Window theme={themeToUse} fitted scrollbars={false}>
      <audio src={resolveAsset('load.mp3')} ref={onLoadPlayer} />
      <Window.Content
        className={classes([
          'LobbyScreen',
          !themeDisabled && 'crtTheme',
          !filterDisabled && 'filterEnabled',
          disableAnimations,
        ])}
        fitted
      >
        <LobbyContext.Provider
          value={{
            animationsDisable: disableAnimations,
            themeDisable: themeDisabled,
            setModal: setModal,
          }}
        >
          {!!modal && <Modal>{modal}</Modal>}
          <Box
            height="100%"
            width="100%"
            style={{
              backgroundImage: `url(${resolveAsset('lobby_art.png')})`,
            }}
            className="bgLoad bgBackground"
          />
          <Box height="100%" width="100%" position="absolute" className="crt" />
          <Box position="absolute" top="10px" right="10px">
            <Button
              icon="cog"
              onClick={() => {
                setModal(
                  <Box className="styledText">
                    <Section
                      p={5}
                      title="Lobby Settings"
                      buttons={
                        <Button icon="xmark" onClick={() => setModal(false)} />
                      }
                      className="styledText"
                    >
                      <Stack>
                        <Stack.Item>
                          <Button
                            icon="tv"
                            onClick={() => {
                              storage.set(
                                'lobby-filter-disabled',
                                !filterDisabled,
                              );
                              setFilterDisabled(!filterDisabled);
                              setModal(false);
                            }}
                            tooltip="Removes the CRT filter background"
                          >
                            {`${filterDisabled ? 'Enable' : 'Disable'} Cinema Mode`}
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="bolt"
                            onClick={() => {
                              storage.set(
                                'lobby-theme-disabled',
                                !themeDisabled,
                              );
                              setThemeDisabled(!themeDisabled);
                              setModal(false);
                            }}
                            tooltip="Totally removes the CRT theme, including the filter"
                          >
                            {`${themeDisabled ? 'Enable' : 'Disable'} CRT Theme`}
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Box>,
                );
              }}
            />
          </Box>
          <Stack vertical height="100%" justify="space-around" align="center">
            <Stack.Item>
              <LobbyButtons setModal={setModal} />
            </Stack.Item>
          </Stack>
          <Box className="bgLoad authorAttrib styledText">
            {lobby_author ? `Art by ${lobby_author}` : ''}
          </Box>
          <Box
            position="absolute"
            left={3}
            top={-2}
            height="100%"
            className="messageHolder"
          >
            <Stack vertical justify="flex-end" fill>
              {preference_issues.map((issue, index) => (
                <Section key={index} className="sectionLoad">
                  <Box>{issue}</Box>
                </Section>
              ))}
            </Stack>
          </Box>
        </LobbyContext.Provider>
      </Window.Content>
    </Window>
  );
};

const ModalConfirm = (props: PropsWithChildren) => {
  const { children } = props;

  const context = useContext(LobbyContext);

  const { setModal } = context;

  return (
    <Section
      buttons={<Button mb={5} onClick={() => setModal!(false)} icon={'x'} />}
      p={3}
      title={'Confirm'}
    >
      {children}
    </Section>
  );
};

const LobbyButtons = (props: { readonly setModal: (_) => void }) => {
  const { act, data } = useBackend<LobbyData>();

  const { setModal } = props;

  const {
    character_name,
    round_start,
    round_starting,
    readied,
    upp_join_enabled,
  } = data;

  return (
    <Section p={3} className="sectionLoad" minWidth="260px">
      <Stack vertical>
        <Stack.Item>
          <Stack vertical align="center">
            <Stack.Item>
              <Box className="typeEffect styledText">Current character:</Box>
            </Stack.Item>
            <Stack.Item>
              <Box
                className="typeEffect styledText"
                style={{
                  animationDelay: '1.4s',
                }}
              >
                {character_name}
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>

        <TimedDivider />

        <LobbyButton
          index={1}
          onClick={() => act('preferences')}
          icon="file-lines"
        >
          Setup Character
        </LobbyButton>

        <TimedDivider />

        <LobbyButton
          index={2}
          icon="eye"
          disabled={!!round_starting}
          onClick={() => {
            setModal(
              <ModalConfirm>
                <Box>
                  <Stack vertical>
                    <Stack.Item>Are you sure you wish to observe?</Stack.Item>
                    <Stack.Item>
                      When you observe, you will not be able to join the round.
                    </Stack.Item>
                  </Stack>
                  <Stack justify="center">
                    <Stack.Item>
                      <Button onClick={() => act('observe')}>Confirm</Button>
                    </Stack.Item>
                  </Stack>
                </Box>
              </ModalConfirm>,
            );
          }}
        >
          Observe
        </LobbyButton>

        {round_start ? (
          <LobbyButton
            index={3}
            selected={!!readied}
            disabled={!!round_starting}
            onClick={() => act(readied ? 'unready' : 'ready')}
            icon={readied ? 'check' : 'xmark'}
          >
            {readied ? 'Unready' : 'Ready'}
          </LobbyButton>
        ) : (
          <>
            <LobbyButton
              index={3}
              disabled={!!round_starting}
              onClick={() => act('late_join')}
              icon="users"
            >
              Join
            </LobbyButton>
            {!!upp_join_enabled && (
              <LobbyButton
                index={4}
                disabled={!!round_starting}
                onClick={() => act('late_join_upp')}
                icon="users-between-lines"
              >
                Join the UPP
              </LobbyButton>
            )}
          </>
        )}
      </Stack>
    </Section>
  );
};

const TimedDivider = () => {
  const ref = useRef<HTMLDivElement>(null);

  const context = useContext(LobbyContext);

  const { themeDisable } = context;

  useEffect(() => {
    if (!themeDisable) {
      setTimeout(() => {
        ref.current!.style.display = 'block';
      }, 1500);
    }
  }, [themeDisable]);

  return (
    <Stack.Item>
      <div
        style={{
          borderStyle: 'solid',
          borderWidth: '1px',
          display: themeDisable ? 'block' : 'none',
        }}
        className="dividerEffect"
        ref={ref}
      />
    </Stack.Item>
  );
};

type LobbyButtonProps = ComponentProps<typeof Box> & {
  readonly index: number;
  readonly selected?: boolean;
  readonly disabled?: boolean;
  readonly icon?: string;
  readonly tooltip?: string;
};

const LobbyButton = (props: LobbyButtonProps) => {
  const { children, index, className, ...rest } = props;

  const context = useContext<LobbyContextType>(LobbyContext);

  return (
    <Stack.Item
      className="buttonEffect"
      style={{
        animationDelay: context.animationsDisable
          ? '0s'
          : `${1.5 + index * 0.2}s`,
      }}
    >
      <Button fluid className={'distinctButton ' + className} {...rest}>
        <StyledText>{children}</StyledText>
      </Button>
    </Stack.Item>
  );
};

const StyledText = (props: PropsWithChildren) => {
  const { children } = props;

  return (
    <Box inline className="styledText">
      {children}
    </Box>
  );
};

const Button = (props) => {
  const { act } = useBackend();

  return (
    <Box onClick={() => act('keyboard')}>
      <NativeButton {...props} />
    </Box>
  );
};
