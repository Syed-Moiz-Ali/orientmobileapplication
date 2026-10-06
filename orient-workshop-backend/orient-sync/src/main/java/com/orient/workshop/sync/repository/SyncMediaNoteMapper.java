package com.orient.workshop.sync.repository;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * Minimal writer for checkpoint notes replayed from the offline queue. Notes
 * share the media_assets index that uploaded photos/videos/audio use, so a
 * single listing returns every asset for a record.
 */
@Mapper
public interface SyncMediaNoteMapper {

    @Delete("DELETE FROM media_assets WHERE module = #{module} AND record_id = #{recordId} "
            + "AND media_type = 'note'")
    int deleteNotes(@Param("module") String module, @Param("recordId") String recordId);

    @Insert("INSERT INTO media_assets "
            + "(ref, tenant, module, record_id, item_id, media_type, url, note, file_name, content_type, size_bytes, created_by, created_at) "
            + "VALUES (#{ref}, #{tenant}, #{module}, #{recordId}, #{itemId}, 'note', '', #{note}, '', 'text/plain', #{size}, #{createdBy}, NOW())")
    int insertNote(@Param("ref") String ref,
                   @Param("tenant") String tenant,
                   @Param("module") String module,
                   @Param("recordId") String recordId,
                   @Param("itemId") String itemId,
                   @Param("note") String note,
                   @Param("size") long size,
                   @Param("createdBy") Long createdBy);
}
