<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk\Exception;

use InvalidArgumentException;

final class UnsupportedLocaleException extends InvalidArgumentException
{
    public function __construct(public readonly string $locale)
    {
        parent::__construct("Unsupported locale: $locale (supported: 'en', 'ar')");
    }
}
