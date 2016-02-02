# org.emacspeak.nature

import random
from boopak.package import *
from boopak.argdef import *
from boodle import agent, stereo
from boodle import builtin
manage = bimport('org.boodler.manage')
play = bimport('org.boodler.play')
birds = bimport('org.emacspeak.birds')
water = bimport('org.boodler.sample.water')
wind = bimport('org.boodler.sample.wind')
rain = bimport('org.boodler.old.water')
soft = bimport('org.boodler.sample.rain')
cricket = bimport('org.boodler.old.insect')
trill = bimport('org.boodler.sample.insect')

ca_mocks = [
    birds.mocking_1, birds.mocking_2, birds.mocking_3,  # CA Mocking Bird
    birds.mocking_4, birds.mocking_5, birds.mocking_6]

fl_mocks = [
    birds.fl_mocking_1, birds.fl_mocking_2, birds.fl_mocking_3,
    birds.fl_mocking_4, birds.fl_mocking_5, birds.fl_mocking_6]

song_birds = [
    birds.songbird_001, birds.songbird_002, birds.songbird_003,
    birds.songbird_004, birds.songbird_005, birds.songbird_006,
    birds.songbird_007, birds.songbird_008, birds.songbird_009,
    birds.songbird_010]

showers = [
    rain.rain_thin, rain.rain_splatter,
    rain.rain_splashy_low, rain.rain_on_leaves,
    rain.rain_med,
    soft.soft_sprinkle, soft.soft_gentle, soft.soft_drizzle]

streams = [
    rain.droplet_bloink,   rain.droplet_plink,
    rain.droplet_plink_reverb_2,   rain.droplet_plink_reverb_3,
    rain.droplet_plink_reverb,
    water.stream_rushing_1, water.stream_rushing_2, water.stream_rushing_3,
    rain.water_bubbling, soft.soft_sprinkle,
    soft.soft_gentle, soft.soft_drizzle, ]

winds = [
    wind.soft_low_1, wind.soft_low_2, wind.soft_low_3,
    wind.gust_soft_1, wind.gust_soft_2, wind.gust_soft_3,
    wind.soft_whistly_1, wind.soft_whistly_2, wind.soft_whistly_3,
    wind.soft_rushy]

bugs = [
    cricket.complex_trilling_trig, cricket.everglades_conehead,
    cricket.fastcalling_tree_cricket, cricket.pine_tree_cricket,
    cricket.house_cricket, cricket.jamaican_field_cricket,
    cricket.japanese_burrowing_cricket, cricket.melodious_ground_cricket,
    cricket.robust_shieldback, cricket.sand_field_cricket,
    cricket.seashore_meadow_katydid, cricket.slightly_musical_conehead,
    cricket.southern_ground_cricket, cricket.syncopated_scaly_cricket,
    cricket.texas_meadow_katydid, cricket.tinking_trig,
    cricket.tinkling_ground_cricket, cricket.tropical_house_cricket,
    cricket.vocal_field_cricket, trill.cricket_loud,
    trill.cricket_ratchety, trill.cricket_scritchy,
    trill.crickets_distant, trill.crickets_low,
    trill.crickets_many_1, trill.cricket_solo_1,
    trill.cricket_solo_2, trill.cricket_solo_3,
    trill.crickets_one_swell,
]


# helper: Pendulum generator:

def pendulum(n):
    """Generate an oscilating sequence."""
    i = 0
    while 1:
        yield abs(i)
        i = i + 1
        if i == n:
            i = -n


class GardenBackground (agent.Agent):

    def init(self, time=0.0):
        self.time = time
        self.pendulum = pendulum(60)

    def run(self):
        count = self.pendulum.next()  # [0, 60]
        gurgle = random.choice(streams)
        breeze = random.choice(winds)
        vol = random.uniform(0.4, 0.6)
        if (count < 15 or count > 45):
            pitch = random.uniform(0.5, 1.1)
        else:
            pitch = random.uniform(0.7, 1.3)
        pan = (count - 30) * 0.05  # [-1.5, 1.5]
        d0 = self.sched_note_pan(gurgle, pan, pitch, vol, self.time)
        self.sched_note_pan(breeze, -1 * pan, pitch, vol,
                            abs(d0 + random.uniform(-2.0, 2.0)))
        if ((count % 6) == 0):
            shower = random.choice(showers)
            self.sched_note_pan(shower, -1.2 * pan, pitch,
                                vol * 0.2,  abs(d0 + random.uniform(-2.0, 2.0)))
        self.resched(abs(d0 + random.uniform(-1.0, -1)))


class FlMockingBirds(agent.Agent):

    _args = ArgList(Arg(type=float), Arg(type=float), Arg(type=float),
                    Arg(type=float), Arg(type=float))

    def init(self,
             minDelay=5.0,
             maxDelay=10.0,
             minVol=0.1,
             maxVol=1.0,
             pan=1.0):
        self.minDelay = minDelay
        self.maxDelay = maxDelay
        self.minVol = minVol
        self.maxVol = maxVol
        self.pan = pan

    def run(self):
        ag = play.IntermittentSoundsList(
            self.minDelay, self.maxDelay,
            0.8, 1.2,  # pitch
            self.minVol, self.maxVol,
            self.pan,
            fl_mocks)
        self.sched_agent(ag)


class CaMockingBirds(agent.Agent):

    _args = ArgList(Arg(type=float), Arg(type=float), Arg(type=float),
                    Arg(type=float), Arg(type=float))

    def init(self,
             minDelay=4.0,
             maxDelay=12.0,
             minVol=0.1,
             maxVol=1.0,
             pan=1.0):
        self.minDelay = minDelay
        self.maxDelay = maxDelay
        self.minVol = minVol
        self.maxVol = maxVol
        self.pan = pan

    def run(self):
        ag = play.IntermittentSoundsList(
            self.minDelay, self.maxDelay,
            0.8, 1.2,  # pitch
            self.minVol, self.maxVol,
            self.pan,
            ca_mocks)
        self.sched_agent(ag)


class SongBirds(agent.Agent):

    _args = ArgList(Arg(type=float), Arg(type=float), Arg(type=float),
                    Arg(type=float), Arg(type=float))

    def init(self,
             minDelay=4.0,
             maxDelay=12.0,
             minVol=0.1,
             maxVol=1.0,
             pan=1.0):
        self.minDelay = minDelay
        self.maxDelay = maxDelay
        self.minVol = minVol
        self.maxVol = maxVol
        self.pan = pan

    def run(self):
        ag = play.IntermittentSoundsList(
            self.minDelay, self.maxDelay,
            0.8, 1.2,  # pitch
            self.minVol, self.maxVol * 0.6,
            self.pan + 0.1,
            song_birds)
        self.sched_agent(ag)


class MockingBirds (agent.Agent):

    def run(self):
        nature = GardenBackground(0.0)
        self.sched_agent(nature)

        ag = CaMockingBirds(5.0, 10.0, 0.1, 0.5, 1.0)
        self.sched_agent(ag)
        ag = CaMockingBirds(30.0, 60.0, 0.1, 0.4, 1.2)
        self.sched_agent(ag)
        ag = CaMockingBirds(60.0, 90.0, 0.1, 0.3, 1.5)
        self.sched_agent(ag)
        ag = FlMockingBirds(5.0, 30.0, 0.05, 0.3, 1.0)
        self.sched_agent(ag)
        ag = FlMockingBirds(30.0, 75.0, 0.1, 0.3, 1.2)
        self.sched_agent(ag)
        ag = FlMockingBirds(10.0, 120.0, 0.1, 0.4, 1.5)
        self.sched_agent(ag)


class ManyMockingBirds (agent.Agent):

    def run(self):
        nature = GardenBackground(0.0)
        self.sched_agent(manage.VolumeModulateAgent(nature, 0.75))

        for _ in xrange(8):
            ag = CaMockingBirds(
                0.0, 120.0,
                0.1, 0.2,
                1.2)
            self.sched_agent(ag)
            ag = FlMockingBirds(
                7.0, 157.0,
                0.1, 0.3,
                1.2)
            self.sched_agent(ag)


class Crickets(agent.Agent):

    _args = ArgList(Arg(type=float), Arg(type=float), Arg(type=float),
                    Arg(type=float), Arg(type=float))

    def init(self,
             minDelay=0.0,
             maxDelay=9.0,
             minVol=0.1,
             maxVol=1.0,
             pan=1.0):
        self.minDelay = minDelay
        self.maxDelay = maxDelay
        self.minVol = minVol
        self.maxVol = maxVol
        self.pan = pan

    def run(self):
        ag = play.IntermittentSoundsList(
            self.minDelay, self.maxDelay,
            0.9, 1.1,  # pitch
            self.minVol, self.maxVol, self.pan,
            bugs)
        self.sched_agent(ag)


class Nightscape (agent.Agent):

    def run(self):
        nature = GardenBackground(0.0)
        self.sched_agent(manage.VolumeModulateAgent(nature, 0.5))

        for i in xrange(6):
            ag = Crickets(
                0.0, 12.0,
                0.1, 0.18, 1.2)
            self.sched_agent(ag)


class BirdChorus (agent.Agent):

    def init(self):
        self.agents = [CaMockingBirds, FlMockingBirds, SongBirds]

    def run(self):
        nature = GardenBackground(0.0)
        self.sched_agent(manage.VolumeModulateAgent(nature, 0.5))

        for i in xrange(len(self.agents)):
            for j in xrange(10):
                start = 30 * i + 10 * j
                ag = self.agents[i](
                    start, 30 + start,  # duration
                    0.075, 0.225,  # volume
                    0.7 + j * 0.05)
                self.sched_agent(ag)


class BirdSongs (agent.Agent):

    def init(self):
        self.agents = [CaMockingBirds, FlMockingBirds, SongBirds]

    def run(self):
        nature = GardenBackground(0.0)
        nc = self.new_channel_pan(stereo.shiftxy(0, -1.5))  # behind you
        self.sched_agent(nature, 0, nc)

        for i in xrange(len(self.agents)):
            for j in xrange(6):
                # compute y using i and j
                # i = 0 approaches, i=1 no change, i=2 recedes
                y = (i - 1) * (2 - j * 0.16)
                bc = self.new_channel_pan(stereo.shiftxy(0, y))
                start = 5 * i + 15 * j
                ag = self.agents[i](
                    start, 30 + start,  # duration
                    0.25, 0.,  # volume
                    0.9 + j * 0.05)
                self.sched_agent(ag, 0, bc)
