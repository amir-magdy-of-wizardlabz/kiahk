<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk\Exception;

use InvalidArgumentException;

final class UnknownFeastException extends InvalidArgumentException
{
    public function __construct(public readonly string $feastId)
    {
        parent::__construct("Unknown feast id: $feastId");
    }
}
