// Fork-only code, included last in colonialmarines.dme so that its definitions come after and override upstream ones.
// Paths are relative to this folder and mirror code/ (code\modules\foo.dm for an override of code\modules\foo.dm).
// Keep the includes in the same sorted order as the DME; validate_dme.py checks both.
#include "code\__DEFINES\cyrillic.dm"
#include "code\datums\changelog.dm"
#include "code\modules\mob\say.dm"
#include "code\modules\mob\living\carbon\human\say.dm"
#include "code\modules\mob\living\carbon\human\whisper.dm"
#include "code\modules\mob\living\carbon\xenomorph\say.dm"
#include "code\modules\unit_tests\_unit_tests.dm"
