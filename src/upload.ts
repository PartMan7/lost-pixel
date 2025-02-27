import { mapLimit } from 'async';
import { MEDIA_UPLOAD_CONCURRENCY } from './config';
import type { PlatformModeConfig } from './config';
import type { ExtendedShotItem } from './types';
import { uploadShot } from './api';
import { log } from './log';
import { parseHrtimeToSeconds } from './utils';

export const uploadRequiredShots = async ({
  config,
  apiToken,
  uploadToken,
  uploadUrl,
  requiredFileHashes,
  extendedShotItems,
}: {
  config: PlatformModeConfig;
  apiToken: string;
  uploadToken: string;
  uploadUrl: string;
  requiredFileHashes: string[];
  extendedShotItems: ExtendedShotItem[];
}) => {
  if (requiredFileHashes.length > 0) {
    log.process('info', 'api', '📤 Uploading shots');

    const uploadStart = process.hrtime();

    const requiredShotItems = extendedShotItems.filter((shotItem) =>
      requiredFileHashes.includes(shotItem.hash),
    );

    await mapLimit<[number, ExtendedShotItem], void>(
      requiredShotItems.entries(),
      MEDIA_UPLOAD_CONCURRENCY,
      async ([index, shotItem]: [number, ExtendedShotItem]) => {
        const logger = log.item({
          shotMode: shotItem.shotMode,
          uniqueItemId: shotItem.shotName,
          itemIndex: index,
          totalItems: requiredShotItems.length,
        });

        await uploadShot({
          config,
          apiToken,
          uploadToken,
          uploadUrl,
          name: `${shotItem.shotMode}/${shotItem.shotName}`,
          file: shotItem.filePathCurrent,
          logger,
        });
      },
    );

    const uploadStop = process.hrtime(uploadStart);

    log.process(
      'info',
      'api',
      `📤 Uploading shots took ${parseHrtimeToSeconds(uploadStop)} seconds`,
    );
  }

  return true;
};
