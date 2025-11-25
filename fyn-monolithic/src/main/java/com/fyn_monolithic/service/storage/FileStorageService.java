package com.fyn_monolithic.service.storage;

import com.fyn_monolithic.model.storage.MediaType;
import com.fyn_monolithic.model.system.FileStorage;
import com.fyn_monolithic.repository.system.FileStorageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FileStorageService {

    private final FileStorageRepository repository;

    public FileStorage saveMetadata(String objectKey, String bucket, String fileName, String contentType, long size, MediaType mediaType) {
        FileStorage storage = new FileStorage();
        storage.setObjectKey(objectKey);
        storage.setBucket(bucket);
        storage.setFileName(fileName);
        storage.setContentType(contentType);
        storage.setSizeBytes(size);
        storage.setMediaType(mediaType);
        return repository.save(storage);
    }
}
