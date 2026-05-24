<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk\Exception;

use InvalidArgumentException;

final class InvalidCopticMonthException extends InvalidArgumentException
{
    public function __construct(public readonly int $month)
    {
        parent::__construct("Invalid Coptic month: $month (must be 1..13)");
    }
}
