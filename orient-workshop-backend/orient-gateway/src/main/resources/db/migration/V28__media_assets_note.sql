-- Notes are assets too: they belong to an inspection checkpoint alongside its
-- photos/videos/audio. Store the note text on the same media index row so a
-- single listing returns every asset for a record.
ALTER TABLE media_assets
    ADD COLUMN note TEXT NULL AFTER url;
