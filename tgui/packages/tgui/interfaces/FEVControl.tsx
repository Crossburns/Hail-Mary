import { useBackend } from '../backend';
import { Box, Button, Section, ProgressBar, Stack, Divider } from '../components';
import { Window } from '../layouts';

type Data = {
  purge_active: boolean;
  override_in_progress: boolean;
  time_remaining: number;
  time_remaining_seconds: number;
  has_power: boolean;
  has_backup: boolean;
  generator_repaired: boolean;
  debug_mode?: boolean;
};

export const FEVControl = (props, context) => {
  const { act, data } = useBackend<Data>(context);

  const timeDisplay = data.purge_active
    ? `${data.time_remaining}:${String(data.time_remaining_seconds).padStart(2, '0')}`
    : '--:--';

  const progressValue = data.purge_active
    ? 1 - (data.time_remaining * 60 + data.time_remaining_seconds) / (15 * 60)
    : 0;

  return (
    <Window width={450} height={400} title="FEV Purge Control System">
      <Window.Content>
        {data.debug_mode && (
          <Section title="DEBUG MODE" color="red">
            <Box color="red" bold mb={1}>
              This console is in debug mode. All safety protocols disabled.
            </Box>
            <Button
              icon="bolt"
              color="red"
              fluid
              fontSize="16px"
              onClick={() => act('instant_trigger')}
            >
              INSTANT TRIGGER - RELEASE FEV NOW
            </Button>
          </Section>
        )}

        <Section title="System Status">
          <Stack vertical>
            <Stack.Item>
              <Box>
                Main Power:{' '}
                <Box as="span" color={data.has_power ? 'good' : 'bad'} bold>
                  {data.has_power ? 'ONLINE' : 'OFFLINE'}
                </Box>
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box>
                Backup Generator:{' '}
                <Box
                  as="span"
                  color={
                    data.generator_repaired
                      ? data.has_backup
                        ? 'good'
                        : 'average'
                      : 'bad'
                  }
                  bold
                >
                  {data.generator_repaired
                    ? data.has_backup
                      ? 'ONLINE'
                      : 'STANDBY'
                    : 'DAMAGED - REPAIRS REQUIRED'}
                </Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>

        <Section
          title="FEV Aerosolization Control"
          buttons={
            !data.purge_active &&
            !data.debug_mode && (
              <Button
                icon="biohazard"
                color="red"
                onClick={() => act('start_purge')}
              >
                INITIATE PURGE
              </Button>
            )
          }
        >
          {data.purge_active ? (
            <Stack vertical fill>
              <Stack.Item>
                <Box color="red" bold fontSize="20px" textAlign="center">
                  PURGE SEQUENCE ACTIVE
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Box textAlign="center" fontSize="32px" bold color="red">
                  {timeDisplay}
                </Box>
                <Box textAlign="center" color="average">
                  Time Until FEV Release
                </Box>
              </Stack.Item>
              <Stack.Item>
                <ProgressBar
                  value={progressValue}
                  ranges={{
                    good: [-Infinity, 0.33],
                    average: [0.33, 0.67],
                    bad: [0.67, Infinity],
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Box mt={2}>
                  {data.override_in_progress ? (
                    <Stack>
                      <Stack.Item grow>
                        <Box color="average" bold>
                          OVERRIDE IN PROGRESS - HOLD POSITION...
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="times"
                          color="red"
                          onClick={() => act('cancel_override')}
                        >
                          Cancel
                        </Button>
                      </Stack.Item>
                    </Stack>
                  ) : (
                    <Button
                      icon="hand-paper"
                      color="yellow"
                      fluid
                      onClick={() => act('start_override')}
                    >
                      MANUAL OVERRIDE (20 seconds)
                    </Button>
                  )}
                </Box>
              </Stack.Item>
            </Stack>
          ) : (
            <Box color="average">
              {data.debug_mode ? (
                <Box>
                  Debug mode active. Use the instant trigger above to immediately
                  release FEV and open the vault.
                </Box>
              ) : (
                <>
                  The FEV aerosolization system is on standby. Initiating a purge
                  will release aerosolized FEV into the atmosphere after a 15
                  minute countdown.
                  <Box mt={2} color="red" bold>
                    WARNING: Unprotected organisms will suffer severe mutagenic
                    effects. Ensure you have proper protective equipment (Power
                    Armor, Hazmat Suit, or Bio Suit).
                  </Box>
                  <Box mt={2} color="label">
                    Upon completion, the Executive Emergency Vault will be
                    unsealed.
                  </Box>
                </>
              )}
            </Box>
          )}
        </Section>

        {!data.debug_mode && (
          <Section title="Countermeasures">
            <Box color="label" fontSize="12px">
              The purge can be stopped by:
              <Box ml={2}>
                - Cutting power to this facility (unless backup generator is
                operational)
              </Box>
              <Box ml={2}>
                - Manual override at this terminal (requires 20 seconds)
              </Box>
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

export default FEVControl;
