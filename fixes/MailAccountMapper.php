<?php
declare(strict_types=1);

/**
 * @author Christoph Wurst <christoph@winzerhof-wurst.at>
 * @author Christoph Wurst <wurst.christoph@gmail.com>
 * @author Lukas Reschke <lukas@owncloud.com>
 * @author Thomas Müller <thomas.mueller@tmit.eu>
 *
 * Mail
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */

namespace OCA\Mail\Db;

use OCP\AppFramework\Db\DoesNotExistException;
use OCP\AppFramework\Db\MultipleObjectsReturnedException;
use OCP\AppFramework\Db\QBMapper;
use OCP\DB\QueryBuilder\IQueryBuilder;
use OCP\IDBConnection;
use OCP\IUser;

class MailAccountMapper extends QBMapper {

	/**
	 * @param IDBConnection $db
	 */
	public function __construct(IDBConnection $db) {
		parent::__construct($db, 'mail_accounts');
	}

   private function getUserClause($qb, $userId) {
            $userObject = \OC::$server->getUserManager()->get($userId);
            $groups = [];
            if ($userObject) {
                    $groups = \OC::$server->getGroupManager()->getUserGroupIds($userObject);
            }
            $or = $qb->expr()->orx();
            $or->add($qb->expr()->eq('user_id', $qb->createNamedParameter($userId)));
            $andx = $qb->expr()->andx();
            $andx->add($qb->expr()->in($qb->func()->substring('user_id', $qb->expr()->literal(8)), $qb->createNamedParameter($groups, IQueryBuilder::PARAM_STR_ARRAY)));
            $andx->add($qb->expr()->eq($qb->func()->substring('user_id', $qb->expr()->literal(1),  $qb->expr()->literal(7)), $qb->expr()->literal("[GROUP]")));
            $or->add($andx);
            return $or;
    }

	/** Finds an Mail Account by id
	 *
	 * @param string $userId
	 * @param int $accountId
	 *
	 * @return MailAccount
	 */
	public function find(string $userId, int $accountId): MailAccount {
		$qb = $this->db->getQueryBuilder();
		$query = $qb
			->select('*')
			->from($this->getTableName())
			->where($this->getUserClause($qb, $userId))
			->andWhere($qb->expr()->eq('id', $qb->createNamedParameter($accountId)));

		return $this->findEntity($query);
	}

	/**
	 * Finds an mail account by id
	 *
	 * @return MailAccount
	 * @throws DoesNotExistException
	 */
	public function findById(int $id): MailAccount {
		$qb = $this->db->getQueryBuilder();
		$query = $qb
			->select('*')
			->from($this->getTableName())
			->where($qb->expr()->eq('id', $qb->createNamedParameter($id)));

		return $this->findEntity($query);
	}

	/**
	 * Finds all Mail Accounts by user id existing for this user
	 *
	 * @param string $userId the id of the user that we want to find
	 *
	 * @return MailAccount[]
	 */
	public function findByUserId(string $userId): array {
		$qb = $this->db->getQueryBuilder();
		$query = $qb
			->select('*')
			->from($this->getTableName())
            ->where($this->getUserClause($qb, $userId));			

		return $this->findEntities($query);
	}

	/**
	 * @throws DoesNotExistException
	 * @throws MultipleObjectsReturnedException
	 */
	public function findProvisionedAccount(IUser $user): MailAccount {
		$qb = $this->db->getQueryBuilder();

		$query = $qb
			->select('*')
			->from($this->getTableName())
			->where(
				$qb->expr()->eq('user_id', $qb->createNamedParameter($user->getUID())),
				$qb->expr()->eq('provisioned', $qb->createNamedParameter(true, IQueryBuilder::PARAM_BOOL))
			);

		return $this->findEntity($query);
	}

	/**
	 * Saves an User Account into the database
	 *
	 * @param MailAccount $account
	 *
	 * @return MailAccount
	 */
	public function save(MailAccount $account): MailAccount {
		if ($account->getId() === null) {
			return $this->insert($account);
		}

		return $this->update($account);
	}

	public function deleteProvisionedAccounts(): void {
		$qb = $this->db->getQueryBuilder();

		$delete = $qb->delete($this->getTableName())
			->where($qb->expr()->eq('provisioned', $qb->createNamedParameter(true, IQueryBuilder::PARAM_BOOL)));

		$delete->execute();
	}

	public function getAllAccounts(): array  {
		$qb = $this->db->getQueryBuilder();
		$query = $qb
			->select('*')
			->from($this->getTableName());

		return $this->findEntities($query);
	}

}
