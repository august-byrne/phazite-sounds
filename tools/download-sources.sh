#!/bin/sh
# SPDX-License-Identifier: CC0-1.0
# Downloads the CC0 sounds that recipes.json takes sounds from, from the commits and files it names, into a folder
# outside the repository. Then, from the repository's folder (README.md, "Making the pack"):
#   phazite_soundkit recipes.json <that folder> pack
# Needs curl and unzip (both in Git Bash on Windows).
set -eu

if [ $# -ne 1 ]; then
    echo "Usage: tools/download-sources.sh <empty folder outside the repository>" >&2
    exit 2
fi

mkdir -p "$1"
cd "$1"

# Downloads a file to a path in this folder; spaces and commas in the address are escaped.
get() {
    mkdir -p "$(dirname "$1")"
    url=$(printf '%s' "$2" | sed 's/ /%20/g; s/,/%2C/g')
    curl -sSfL --retry 2 -o "$1" "$url"
    echo "$1"
}

VIRT=https://raw.githubusercontent.com/sfzinstruments/virtuosity_drums/9f04cf9a734527edfbb0a4eee1f674e45bbf71bc/Samples/mid
get virt/kick.flac "$VIRT/kick/mid_kick_snoff_vl4_rr1.flac"
get virt/snare_center.flac "$VIRT/snare/mid_snare_center_vl30.flac"
get virt/snare_rimshot.flac "$VIRT/snare/mid_snare_rimshot_vl8.flac"
get virt/snare_crossstick.flac "$VIRT/snare/mid_snare_crossstick_vl12.flac"
get virt/hh_closed.flac "$VIRT/hh/mid_hh_closed_vl3_rr1.flac"
get virt/hh_pedal.flac "$VIRT/hh/mid_hh_pedal_vl2_rr1.flac"
get virt/hh_open.flac "$VIRT/hh/mid_hh_open_vl3_rr1.flac"
get virt/crash.flac "$VIRT/crash/mid_crash_crash_vl2_rr1.flac"
get virt/ride.flac "$VIRT/ride/mid_ride_ride_vl2_rr1.flac"
get virt/ride_bell.flac "$VIRT/ride/mid_ride_bell_vl2_rr1.flac"

BRD=https://raw.githubusercontent.com/sfzinstruments/karoryfer.big-rusty-drums/f07ce00df34a46b6b08375be56fe116cf15782bc/Samples
get brd/kick_close.flac "$BRD/kick_24/kick/kick/k_vl12_rr1.flac"
get brd/tom18_close.flac "$BRD/tom_18/center/cl/t18_vl6_rr1.flac"

BODY=https://raw.githubusercontent.com/sfzinstruments/body_percussion/4ac9d8966679c648b62fa10a188179e186b97f24/Samples/body
get body/handclap.wav "$BODY/handclap_vl2_rr1.wav"
get body/snap.wav "$BODY/snap_r_rr1.wav"
get body/fingerclap.wav "$BODY/fingerclap_vl2_rr1.wav"

FREEPATS=https://raw.githubusercontent.com/freepats/synthesizer-percussion/39bbabce8e0e10aa259d5d94fca329f668733185/samples
for name in Kick04 Kick06 Snare09 Clap01 ClosedHiHat01-01 OpenHiHat02-01 Cymbal02 MidTom02-01; do
    get "freepats/$name.flac" "$FREEPATS/$name.flac"
done

SONICPI=https://raw.githubusercontent.com/sonic-pi-net/sonic-pi/f4c680462539dfc80053caba65dff8200b93e7f9/etc/samples
for name in bd_sone ambi_swoosh ambi_dark_woosh ambi_lunar_land; do
    get "sonicpi/$name.flac" "$SONICPI/$name.flac"
done

VCSL=https://raw.githubusercontent.com/sgossner/VCSL/c1ea7bcc3c7309650ab0da9d15c9cd1fbc4a4c7e
get vcsl/snare_modern1.wav "$VCSL/Membranophones/Struck Membranophones/Snare Drum, Modern 1/Snare2_HitSN_v7_rr1_Mid.wav"
get vcsl/snare_modern3_rimshot.wav "$VCSL/Membranophones/Struck Membranophones/Snare Drum, Modern 3/Snare4_rimshot_v4_rr1_Mid.wav"
get vcsl/clap.wav "$VCSL/Idiophones/Struck Idiophones/Claps/Clap_rr1.wav"
get vcsl/hihat_closed.wav "$VCSL/Idiophones/Struck Idiophones/Hi-Hat Cymbal/HiHat_HitC_v3_rr1_Mid.wav"
get vcsl/tom_high.wav "$VCSL/Membranophones/Struck Membranophones/Tom 1/Stick/TomH_HitS_v3_rr1_Mid.wav"
get vcsl/tom_low.wav "$VCSL/Membranophones/Struck Membranophones/Tom 2/Stick/TomL_HitS_v3_rr1_Mid.wav"
get vcsl/shaker.wav "$VCSL/Idiophones/Struck Idiophones/Shaker, Small/Mid_ShakerDouble_Down_rr1.wav"
get vcsl/tambourine_hit.wav "$VCSL/Idiophones/Struck Idiophones/Tambourine 1/Tamb1_Hit_v2_rr1_Mid.wav"
get vcsl/tambourine_shake.wav "$VCSL/Idiophones/Struck Idiophones/Tambourine 1/Tamb1_Shake_rr1_Mid.wav"
get vcsl/conga.wav "$VCSL/Membranophones/Struck Membranophones/Conga/Conga_HitN_v2_rr1_Sum.wav"
get vcsl/tumba.wav "$VCSL/Membranophones/Struck Membranophones/Conga/Tumba_HitN_v2_rr1_Sum.wav"
get vcsl/bongo_high.wav "$VCSL/Membranophones/Struck Membranophones/Bongos/BongoH_Hit1_v2_rr1_Mid.wav"
get vcsl/bongo_low.wav "$VCSL/Membranophones/Struck Membranophones/Bongos/BongoL_Hit1_v2_rr1_Mid.wav"
get vcsl/cowbell.wav "$VCSL/Idiophones/Struck Idiophones/Cowbells/Cowbell1_Hit_v3_rr1_Mid.wav"
get vcsl/claves.wav "$VCSL/Idiophones/Struck Idiophones/Claves/Claves1_Hit_v2_rr1_Mid.wav"
get vcsl/cymbal_swell.wav "$VCSL/Idiophones/Struck Idiophones/Suspended Cymbal 1/susCymb1_cresc_4s.wav"
get vcsl/bassdrum_concert.wav "$VCSL/Membranophones/Struck Membranophones/Bass Drum 2/bassdrum_hit_ff.wav"
get vcsl/gong.wav "$VCSL/Idiophones/Struck Idiophones/Gong 1/gong_f.wav"
get vcsl/anvil.wav "$VCSL/Idiophones/Struck Idiophones/Anvil/Anvil_Hit2_v2_rr1_Mid.wav"

get archive/eatme_108.flac "https://archive.org/download/108_bpm_breakbeat_to_use/Sample00_108_BPM_EatMe_drums_-_2016_-_samples_-_music_by_EatMe_-_www.eatme.pro_-_drums_recorded_with_2_overhead_microphones_through_mix_amp_on_minidisc_to_computer..flac"

get kenney/rpg-audio.zip "https://kenney.nl/media/pages/assets/rpg-audio/8e99002d76-1677590336/kenney_rpg-audio.zip"
get kenney/impact-sounds.zip "https://kenney.nl/media/pages/assets/impact-sounds/87b4ddecda-1677589768/kenney_impact-sounds.zip"
unzip -q -o kenney/rpg-audio.zip -d kenney/rpg
unzip -q -o kenney/impact-sounds.zip -d kenney/impact
