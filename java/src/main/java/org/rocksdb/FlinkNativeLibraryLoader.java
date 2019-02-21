/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.rocksdb;

import org.rocksdb.util.Environment;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

class FlinkNativeLibraryLoader {
    private static final FlinkNativeLibraryLoader instance = new FlinkNativeLibraryLoader();
    private static boolean initialized = false;

    private static final String tempFilePrefix = "librocksdb_plugins";
    private static final String tempFileSuffix = getJniLibraryExtension();
    private static final String jniLibraryFileName = tempFilePrefix + tempFileSuffix;

    static FlinkNativeLibraryLoader getInstance() {
        return instance;
    }

    void loadLibraryFromJar(final String tmpDir) throws IOException {
        if (!initialized) {
            File lib = loadLibraryFromJarToTemp(tmpDir);
            NativeLibraryLoader.getInstance().loadLibraryFromJarToTemp(lib.getParent());
            System.load(lib.getAbsolutePath());
            initialized = true;
        }
    }

    private File loadLibraryFromJarToTemp(final String tmpDir)
            throws IOException {
        final File temp;
        if (tmpDir == null || tmpDir.isEmpty()) {
            temp = File.createTempFile(tempFilePrefix, tempFileSuffix);
        } else {
            temp = new File(tmpDir, jniLibraryFileName);
            if (temp.exists() && !temp.delete()) {
                throw new RuntimeException("File: " + temp.getAbsolutePath()
                        + " already exists and cannot be removed.");
            }
            if (!temp.createNewFile()) {
                throw new RuntimeException("File: " + temp.getAbsolutePath()
                        + " could not be created.");
            }
        }

        if (!temp.exists()) {
            throw new RuntimeException("File " + temp.getAbsolutePath() + " does not exist.");
        } else {
            temp.deleteOnExit();
        }

        // attempt to copy the library from the Jar file to the temp destination
        try (final InputStream is = getClass().getClassLoader().
                getResourceAsStream(jniLibraryFileName)) {
            if (is == null) {
                throw new RuntimeException(jniLibraryFileName + " was not found inside JAR.");
            } else {
                Files.copy(is, temp.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
        }

        return temp;
    }

    private static String getJniLibraryExtension() {
        if (Environment.isWindows()) {
            return ".dll";
        }
        return (Environment.isMac()) ? ".dylib" : ".so";
    }
}
