## Table `health_logs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  |
| `cycle_day` | `int4` |  Nullable |
| `symptom_notes` | `text` |  Nullable |
| `pain_scale` | `int4` |  Nullable |
| `logged_date` | `timestamptz` |  Nullable |

## Table `medical_knowledge_base`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int4` | Primary |
| `category` | `text` |  Nullable |
| `medical_fact` | `text` |  Nullable |
| `friendly_advice` | `text` |  Nullable |
| `embedding` | `vector` |  Nullable |

## Table `symptom_logs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int8` | Primary Identity |
| `user_id` | `uuid` |  |
| `log_date` | `date` |  |
| `mood` | `int4` |  Nullable |
| `severity` | `int4` |  Nullable |
| `physical_symptoms` | `_text` |  Nullable |
| `emotional_symptoms` | `_text` |  Nullable |
| `lifestyle_symptoms` | `_text` |  Nullable |
| `notes` | `text` |  Nullable |
| `created_at` | `timestamptz` |  |

## Table `sleep_logs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `int8` | Primary Identity |
| `user_id` | `uuid` |  |
| `log_date` | `date` |  |
| `sleep_time` | `timestamptz` |  |
| `wake_time` | `timestamptz` |  |
| `duration_minutes` | `int4` |  |
| `quality` | `text` |  Nullable |
| `created_at` | `timestamptz` |  |

## Table `profiles`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` |  |
| `full_name` | `text` |  Nullable |
| `email` | `text` |  |
| `dob` | `date` |  Nullable |
| `height` | `numeric` |  Nullable |
| `weight` | `numeric` |  Nullable |
| `last_period_start` | `date` |  Nullable |
| `cycle_length` | `int4` |  Nullable |
| `period_length` | `int4` |  Nullable |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |
| `partner_code` | `text` |  Nullable Unique |
| `role` | `text` |  Nullable |

## Table `daily_logs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  |
| `date` | `date` |  |
| `mood` | `text` |  Nullable |
| `symptoms` | `_text` |  Nullable |
| `severity` | `int4` |  Nullable |
| `personal_notes` | `text` |  Nullable |
| `sleep_start_time` | `text` |  Nullable |
| `sleep_end_time` | `text` |  Nullable |
| `sleep_quality` | `text` |  Nullable |
| `sleep_total_minutes` | `int4` |  Nullable |
| `hydration_goal` | `int4` |  Nullable |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

## Table `hydration_logs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  |
| `log_date` | `date` |  |
| `amount` | `int4` |  |
| `time` | `text` |  |
| `type` | `text` |  |
| `logged_at` | `timestamptz` |  Nullable |

## Table `period_cycles`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  |
| `start_date` | `date` |  |
| `end_date` | `date` |  Nullable |
| `cycle_length` | `int4` |  Nullable |
| `period_length` | `int4` |  Nullable |
| `created_at` | `timestamptz` |  Nullable |

## Table `notification_settings`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  Unique |
| `period_reminder` | `bool` |  Nullable |
| `period_days_before` | `int4` |  Nullable |
| `period_time` | `text` |  Nullable |
| `ovulation_reminder` | `bool` |  Nullable |
| `hydration_reminder` | `bool` |  Nullable |
| `hydration_interval` | `text` |  Nullable |
| `sleep_reminder` | `bool` |  Nullable |
| `sleep_time` | `text` |  Nullable |
| `symptom_reminder` | `bool` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

## Table `app_settings`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  Unique |
| `language` | `text` |  Nullable |
| `theme` | `text` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

## Table `chat_messages`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  |
| `role` | `text` |  |
| `content` | `text` |  |
| `timestamp` | `timestamptz` |  Nullable |

## Table `partner_connections`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `requester_id` | `uuid` |  |
| `receiver_id` | `uuid` |  |
| `status` | `text` |  Nullable |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

