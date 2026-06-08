import pytest
from pydantic import ValidationError

from app.schemas.profile import MOMENT_NOTE_MAX_LENGTH, DailyMomentCreate


def test_moment_note_accepts_long_content():
    note = "今" * MOMENT_NOTE_MAX_LENGTH
    payload = DailyMomentCreate(
        event_tags=["其它"],
        emotion_tag="calm",
        note=note,
    )
    assert payload.note == note


def test_moment_note_rejects_over_limit():
    note = "今" * (MOMENT_NOTE_MAX_LENGTH + 1)
    with pytest.raises(ValidationError):
        DailyMomentCreate(
            event_tags=["其它"],
            emotion_tag="calm",
            note=note,
        )
