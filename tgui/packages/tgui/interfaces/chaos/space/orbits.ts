// Orbits of a star system view: where planets and moons go around the star, seen from above at an angle.

export type Size = { width: number; height: number };

export type Point = { x: number; y: number };

/** What the orbits need of an origin */
export type OrbitingOrigin = {
  name: string;
  /** Diameter of its planet in px */
  planet_size: number;
  /** Name of the origin whose planet it orbits as a moon, or null for a planet of the star */
  moon_of: string | null;
};

/** A planet orbiting the star, or a moon orbiting a planet */
export type Body<Origin extends OrbitingOrigin> = {
  origin: Origin;
  /** Index of the planet a moon orbits in the bodies, null for a planet */
  parent: number | null;
  /** Radius of a moon's orbit around its planet in px, 0 for a planet */
  moonRadius: number;
};

/** Height of the orbit ellipses to their width, as if the system is seen from above at an angle */
export const ORBIT_TILT = 0.55;
/** Space between the outer orbit and the edge of the view, in px */
const ORBIT_MARGIN = 70;
/** Room between the edges of planets on neighbouring orbits, in px, before the orbits are spread over the view */
const ORBIT_GAP = 12;
/**
 * Seconds for a turn of every planet around the star. They all turn together, so they keep the angles between them
 * from START_ANGLE_STEP and never pass each other: the view is too small to space the orbits so wide that planets on
 * neighbouring ones can't overlap.
 */
const PLANET_PERIOD = 90;
/** Room between a planet and the orbit of its first moon, and between the orbits of its moons, in px */
const MOON_GAP = 6;
/** Seconds for a turn of a moon whose orbit is as wide as its planet; wider ones are slower */
const MOON_PERIOD = 10;
/**
 * Angle between the starting points of neighbouring bodies, in radians, so they don't start in a line. The planets keep
 * it as they turn, so planets on neighbouring orbits stay on far sides of the star.
 */
const START_ANGLE_STEP = 2.4;
/** How far the light source is from the middle of a body towards the star, in the body's sizes */
const LIGHT_DISTANCE = 0.35;

// Stacking of the bodies: planets go behind the star on the far half of their orbits, moons behind their planets
const Z_FAR = 10;
export const Z_STAR = 20;
const Z_NEAR = 30;

/**
 * Returns the bodies of the system: the planets in the order of the origins, then the moons of each planet, the closest
 * first. A moon of an origin that isn't a planet of the system is shown as a planet.
 */
export const getBodies = <Origin extends OrbitingOrigin>(
  origins: Origin[],
): Body<Origin>[] => {
  const planetNames = new Set(
    origins.filter((entry) => !entry.moon_of).map((entry) => entry.name),
  );
  const isMoon = (entry: Origin) =>
    !!entry.moon_of && planetNames.has(entry.moon_of);
  const planets = origins.filter((entry) => !isMoon(entry));
  const bodies: Body<Origin>[] = planets.map((origin) => ({
    origin,
    parent: null,
    moonRadius: 0,
  }));
  planets.forEach((planet, planetIndex) => {
    let reach = planet.planet_size / 2;
    for (const moon of origins) {
      if (!isMoon(moon) || moon.moon_of !== planet.name) {
        continue;
      }
      const moonRadius = reach + MOON_GAP + moon.planet_size / 2;
      reach = moonRadius + moon.planet_size / 2;
      bodies.push({ origin: moon, parent: planetIndex, moonRadius });
    }
  });
  return bodies;
};

/** Returns the starting angles of the bodies on their orbits, in radians */
export const getStartAngles = (bodies: Body<OrbitingOrigin>[]) =>
  bodies.map((_, index) => index * START_ANGLE_STEP);

/** Diameter of a planet with the orbits of its moons, which its orbit needs room for */
const getPlanetReach = (bodies: Body<OrbitingOrigin>[], planetIndex: number) =>
  bodies.reduce(
    (reach, body) =>
      body.parent === planetIndex
        ? Math.max(reach, (body.moonRadius + body.origin.planet_size / 2) * 2)
        : reach,
    bodies[planetIndex].origin.planet_size,
  );

/**
 * Returns the radii of the planets' orbits, the closest first: the inner one clears the star's flares, the outer one
 * fills the view, and the room between neighbouring orbits follows the sizes of their planets with their moons, so big
 * planets get more of it
 */
export const getOrbitRadii = (
  bodies: Body<OrbitingOrigin>[],
  starSize: number,
  view: Size,
) => {
  const planetSizes = bodies
    .filter((body) => body.parent === null)
    .map((_, index) => getPlanetReach(bodies, index));
  if (!planetSizes.length) {
    return [];
  }
  const outer = Math.max(
    Math.min(
      view.width / 2 - ORBIT_MARGIN,
      (view.height / 2 - ORBIT_MARGIN) / ORBIT_TILT,
    ),
    0,
  );
  // The flares reach out to the star's diameter from its middle
  const inner = Math.min(outer, starSize + planetSizes[0] / 2);
  if (planetSizes.length === 1) {
    return [(inner + outer) / 2];
  }
  const steps = planetSizes
    .slice(1)
    .map(
      (planetSize, index) => (planetSizes[index] + planetSize) / 2 + ORBIT_GAP,
    );
  const scale = (outer - inner) / steps.reduce((sum, step) => sum + step, 0);
  const radii = [inner];
  for (const step of steps) {
    radii.push(radii[radii.length - 1] + step * scale);
  }
  return radii;
};

/**
 * Seconds for a turn of the body: the same for all planets (see PLANET_PERIOD), and for a moon growing with its orbit's
 * radius to the power of 1.5 (Kepler's third law)
 */
export const getOrbitPeriod = (body: Body<OrbitingOrigin>) =>
  body.parent === null
    ? PLANET_PERIOD
    : MOON_PERIOD * Math.pow(body.moonRadius / body.origin.planet_size, 1.5);

const getOrbitPosition = (
  center: Point,
  radius: number,
  angle: number,
): Point => ({
  x: center.x + radius * Math.cos(angle),
  y: center.y + radius * ORBIT_TILT * Math.sin(angle),
});

/** Returns where the bodies are in the view, at their angles */
export const getBodyPositions = (
  bodies: Body<OrbitingOrigin>[],
  radii: number[],
  view: Size,
  angles: number[],
) => {
  const star = { x: view.width / 2, y: view.height / 2 };
  const positions: Point[] = [];
  bodies.forEach((body, index) => {
    positions.push(
      body.parent === null
        ? getOrbitPosition(star, radii[index] ?? 0, angles[index])
        : getOrbitPosition(
            positions[body.parent],
            body.moonRadius,
            angles[index],
          ),
    );
  });
  return positions;
};

/** Returns the z-index of each body at its position: in front of the star on the near half, moons around their planets */
export const getBodyLayers = (
  bodies: Body<OrbitingOrigin>[],
  positions: Point[],
  view: Size,
) => {
  const layers: number[] = [];
  bodies.forEach((body, index) => {
    const position = positions[index];
    if (body.parent === null) {
      layers.push(position.y > view.height / 2 ? Z_NEAR : Z_FAR);
      return;
    }
    const parent = positions[body.parent];
    layers.push(layers[body.parent] + (position.y > parent.y ? 1 : -1));
  });
  return layers;
};

/** Returns the light of a body from the star in the middle of the view, as PixelPlanet light: in front of the body's middle */
export const getStarLight = (position: Point, view: Size) => {
  const towardsX = view.width / 2 - position.x;
  const towardsY = view.height / 2 - position.y;
  const distance = Math.hypot(towardsX, towardsY) || 1;
  return [
    0.5 + (towardsX / distance) * LIGHT_DISTANCE,
    0.5 + (towardsY / distance) * LIGHT_DISTANCE,
  ];
};
